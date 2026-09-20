#!/usr/bin/env python3
"""实时设备功耗监控 (Arrow Lake-H / ThinkBook 14 G7+ IAH)

需要 sudo 运行以读取 RAPL energy_uj 和 intel_gpu_top。
非 root 模式仅显示 CPU/GPU频率/屏幕背光等有限数据。

数据源:
  RAPL powercap     → package / core / uncore / psys (平台总功耗)
  intel_gpu_top     → GPU 引擎利用率 (busy%), 配合频率估算 GPU 功耗
  电池 power_now    → 系统总功耗交叉校验 (仅放电时有数据)
  背光 sysfs        → 屏幕亮度 → 功耗估算
  CPU cpufreq/stat  → 利用率 + 各核频率
  sensors           → CPU/SSD/WiFi 温度
"""

import os, sys, time, json, signal, subprocess
from pathlib import Path
from collections import deque
from datetime import datetime

# ═══ 配置 ═══════════════════════════════════════════════════
INTERVAL = 0.5
AVG_WINDOW = 10
GPU_TDP = 28.0            # Arc 130T/140T 典型 TDP (W)
SCREEN_MAX_W = 5.0        # 14" 3K @ 100% 亮度估算 (W)
RAPL_WRAP = 1 << 48       # RAPL 计数器溢出边界

# 设备路径
RAPL = {
    "pkg": "/sys/class/powercap/intel-rapl:0/energy_uj",
    "core": "/sys/class/powercap/intel-rapl:0/intel-rapl:0:0/energy_uj",
    "uncore": "/sys/class/powercap/intel-rapl:0/intel-rapl:0:1/energy_uj",
    "psys": "/sys/class/powercap/intel-rapl:1/energy_uj",
}
BAT = Path("/sys/class/power_supply/BAT1")
BL = Path("/sys/class/backlight/intel_backlight")
GPU = Path("/sys/class/drm/card1")

# ═══ ANSI ═══════════════════════════════════════════════════
class ANSI:
    HIDE = "\033[?25l"
    SHOW = "\033[?25h"
    HOME = "\033[H"
    CLEAR = "\033[J"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    R = "\033[0m"
    @staticmethod
    def rgb(r, g, b, text):
        return f"\033[38;2;{r};{g};{b}m{text}\033[0m"
    @staticmethod
    def grad(val, lo, hi, fmt="{:6.1f}", unit="W"):
        """低→绿 中→黄 高→红"""
        ratio = max(0, min(1, (val - lo) / (hi - lo))) if hi > lo else 0
        if ratio < 0.3:
            code = "32"  # green
        elif ratio < 0.7:
            code = "33"  # yellow
        else:
            code = "31"  # red
        return f"\033[{code}m{fmt.format(val)}{unit}\033[0m"

def bar(val, mx, w=25):
    if mx <= 0: return "░" * w
    n = min(int(val / mx * w), w)
    return "█" * n + "░" * (w - n)

# ═══ 读取函数 ═══════════════════════════════════════════════

def read_rapl():
    """返回 {name: energy_µJ | None}"""
    out = {}
    for k, p in RAPL.items():
        try:
            out[k] = int(Path(p).read_text().strip())
        except (OSError, ValueError):
            out[k] = None
    return out

def rapl_delta(prev, curr, dt_s):
    """两次采样间功率 (W)"""
    out = {}
    for k in RAPL:
        pv, cv = prev.get(k), curr.get(k)
        if pv is not None and cv is not None and dt_s > 0:
            d = cv - pv
            if d < 0:
                d += RAPL_WRAP
            out[k] = d / (dt_s * 1e6)
    return out

def read_battery():
    try:
        return {
            "voltage": int((BAT / "voltage_now").read_text().strip()) / 1e6,
            "current": int((BAT / "current_now").read_text().strip()) / 1e6,
            "power":   abs(int((BAT / "power_now").read_text().strip())) / 1e6,
            "status":  (BAT / "status").read_text().strip(),
            "cap_pct": int((BAT / "capacity").read_text().strip()),
            "energy":  int((BAT / "energy_now").read_text().strip()) / 1e6,
            "energy_full": int((BAT / "energy_full").read_text().strip()) / 1e6,
        }
    except Exception:
        return None

def read_backlight():
    try:
        a = int((BL / "actual_brightness").read_text().strip())
        m = int((BL / "max_brightness").read_text().strip())
        return a / m if m else 0
    except Exception:
        return 0

def read_cpu():
    """返回 (util%, avg_freq_MHz, freqs_dict)"""
    try:
        txt = Path("/proc/stat").read_text()
        for line in txt.splitlines():
            if line.startswith("cpu "):
                return [int(x) for x in line.split()[1:]]
    except Exception:
        pass
    return None

def cpu_delta(p, c):
    if not p or not c: return 0.0
    prev_idle = p[3] + p[4]
    curr_idle = c[3] + c[4]
    d_total = sum(c) - sum(p)
    d_idle = curr_idle - prev_idle
    return (d_total - d_idle) / d_total if d_total > 0 else 0.0

def read_freqs():
    fs = {}
    for d in sorted(Path("/sys/devices/system/cpu/").glob("cpu[0-9]*")):
        try:
            fs[d.name] = int((d / "cpufreq/scaling_cur_freq").read_text().strip()) / 1000
        except Exception:
            pass
    return fs

def read_gpu():
    """返回 {freq, freq_max, busy, power_est}"""
    try:
        freq = int((GPU / "gt_cur_freq_mhz").read_text().strip())
        fmax = int((GPU / "gt_max_freq_mhz").read_text().strip())
    except Exception:
        freq, fmax = 0, 2200

    busy = 0.0
    # intel_gpu_top (需要 root/CAP_PERFMON)
    try:
        cp = subprocess.run(
            ["intel_gpu_top", "-J", "-s", "1"],
            capture_output=True, text=True, timeout=3,
            env={**os.environ, "INTEL_GPU_TOP_INTERVAL": "0.5"},
        )
        if cp.returncode == 0:
            data = json.loads(cp.stdout)
            engines = data.get("engines", {}) if isinstance(data, dict) else {}
            for name, info in engines.items():
                if isinstance(info, dict):
                    busy = max(busy, info.get("busy", 0))
    except Exception:
        pass

    fpct = freq / fmax if fmax else 0
    power_est = fpct * (busy / 100) * GPU_TDP
    return {"freq": freq, "freq_max": fmax, "busy": busy, "power_est": power_est}

def read_temps():
    t = {}
    try:
        cp = subprocess.run(["sensors", "-j"], capture_output=True, text=True, timeout=2)
        if cp.returncode != 0: return t
        data = json.loads(cp.stdout)
        for dev, sensors in data.items():
            if "coretemp" in dev:
                for k, v in sensors.items():
                    if not isinstance(v, dict): continue
                    if "Package" in k:
                        for tk, tv in v.items():
                            if tk.endswith("_input"):
                                t["cpu"] = tv
                    elif k.startswith("Core"):
                        for tk, tv in v.items():
                            if tk.endswith("_input"):
                                t["cpu_max"] = max(t.get("cpu_max", 0), tv)
    except Exception:
        pass
    return t

# ═══ 渲染 ═══════════════════════════════════════════════════

def render(snapshot):
    """snapshot = {pkg, core, uncore, psys, total, gpu, screen, cpu_util, avg_freq,
                   temps, bat, dt_ms, is_root} + avg_* 滑动均值"""
    s = snapshot
    out = []
    ts = datetime.now().strftime("%H:%M:%S")

    out.append(ANSI.HOME)
    out.append(f"╔══════════════════════════════════════════════════════════╗")
    out.append(f"║  {ANSI.BOLD}实时设备功耗监控{ANSI.R}  {ts}  {ANSI.DIM}({INTERVAL}s 采样, {AVG_WINDOW}s 平滑){ANSI.R}")

    # 总功耗
    total_str = f"{ANSI.BOLD}{s['total']:6.1f} W{ANSI.R}" if s["total"] else f"{ANSI.DIM}   N/A{ANSI.R}"
    src = ""
    if s["psys_ok"]: src = "psys"
    elif s["pkg_ok"]: src = "pkg"
    elif s["bat_discharging"]: src = "电池"
    else: src = "无数据源"

    bat_str = ""
    if s["bat"]:
        b = s["bat"]
        icon = {"Charging": "🔌", "Discharging": "🔋", "Not charging": "⚡"}.get(b["status"], "")
        bp = f"{b['power']:.1f}W" if b["power"] > 0.5 else "≈0W"
        bat_str = f"    {icon} 电池 {b['cap_pct']}%  {b['energy']:.0f}/{b['energy_full']:.0f}Wh  {bp}  {b['voltage']:.2f}V"

    out.append(f"╠══════════════════════════════════════════════════════════╣")
    out.append(f"  {ANSI.BOLD}总功耗{ANSI.R}  {total_str}  ← {src}{bat_str}")

    # 部件表头
    out.append(f"╟──────────────────────────────────────────────────────────╢")
    out.append(f"  {'部件':<14}{'瞬时':>8}  {'平均':>8}  {'占比':>6}  {'详情'}")
    out.append(f"  {'─'*14}{'─'*8}  {'─'*8}  {'─'*6}  {'─'*25}")

    total = s["total"] or 0
    rows = [
        ("Package",    s["pkg"],    s["avg_pkg"],    5, 45, ""),
        ("  ├ Core",   s["core"],   s["avg_core"],   2, 35, ""),
        ("  └ Uncore", s["uncore"], s["avg_uncore"], 2, 15, ""),
        ("GPU (估算)", s["gpu"],    s["avg_gpu"],    1, 20,
         f"freq {s['gpu_freq']}/{s['gpu_fmax']}MHz  busy {s['gpu_busy']:.0f}%" if s["gpu_freq"] else ""),
        ("屏幕(估算)", s["screen"], s["avg_screen"],  0.5, 4,
         f"亮度 {s['bl_pct']*100:.0f}%" if s["bl_pct"] is not None else ""),
    ]
    for label, val, avg_v, lo, hi, detail in rows:
        if val is None: continue
        pct = f"{val/total*100:.1f}%" if total > 0 and val > 0 else ""
        out.append(f"  {label:<14}{ANSI.grad(val, lo, hi):>14}  {ANSI.grad(avg_v, lo, hi):>14}  {pct:>6}  {detail}")

    # Psys 行 (有数据时)
    if s["psys"] is not None and s["psys"] > 0:
        pct_psys = f"{s['psys']/total*100:.1f}%" if total > 0 else ""
        out.append(f"  {'Psys(平台)':<14}{ANSI.grad(s['psys'], 5, 50):>14}  {ANSI.grad(s['avg_psys'], 5, 50):>14}  {pct_psys:>6}  平台总功耗")

    out.append(f"╟──────────────────────────────────────────────────────────╢")

    # CPU
    out.append(f"  {ANSI.BOLD}CPU 利用率{ANSI.R} {s['cpu_util']*100:5.1f}% {bar(s['cpu_util'], 1.0)}  均频 {s['avg_freq']:.0f}MHz")
    if s.get("temp_cpu"):
        tc = s["temp_cpu"]
        tc_str = ANSI.grad(float(tc), 40, 85, fmt="{:5.1f}", unit="°C")
        tmax = s.get("temp_max") or 0
        out.append(f"  {ANSI.BOLD}CPU 温度{ANSI.R}  {tc_str}  (最高核 {float(tmax):.0f}°C)")
    if s["gpu_freq"] and s["gpu_fmax"]:
        out.append(f"  {ANSI.BOLD}GPU 频率{ANSI.R} {s['gpu_freq']}/{s['gpu_fmax']}MHz {bar(s['gpu_freq']/s['gpu_fmax'], 1.0)}")

    out.append(f"╚══════════════════════════════════════════════════════════╝")
    out.append(f"{ANSI.DIM}  Ctrl+C 退出  |  dt={s['dt_ms']:.0f}ms  |  {'✓ RAPL' if s['is_root'] else '✗ RAPL (需要 root)'}{ANSI.R}")

    return "\n".join(out)

# ═══ 主循环 ═════════════════════════════════════════════════

def main():
    signal.signal(signal.SIGINT, lambda *_: None)
    signal.signal(signal.SIGTERM, lambda *_: None)
    is_root = os.geteuid() == 0

    if not is_root:
        print(f"\033[1;33m⚠ 非 root — RAPL 和 intel_gpu_top 不可用\033[0m")
        print(f"  sudo python3 {__file__}")
        print(f"  继续以受限模式运行...\n")
        time.sleep(1.5)

    # 历史窗口
    hist = {k: deque(maxlen=AVG_WINDOW) for k in ["pkg", "core", "uncore", "psys", "gpu", "screen", "total"]}
    prev_rapl = read_rapl() if is_root else None
    prev_stat = read_cpu()
    prev_t = time.monotonic()

    print(ANSI.HIDE, end="", flush=True)
    try:
        while True:
            now = time.monotonic()
            dt = now - prev_t

            # RAPL
            curr_rapl = read_rapl() if is_root else None
            rapl = rapl_delta(prev_rapl, curr_rapl, dt) if prev_rapl and curr_rapl else {}

            # CPU
            curr_stat = read_cpu()
            util = cpu_delta(prev_stat, curr_stat)
            freqs = read_freqs()
            avg_f = sum(freqs.values()) / len(freqs) if freqs else 0

            # GPU
            gpu = read_gpu()

            # 背光
            bl_pct = read_backlight()
            screen = bl_pct * SCREEN_MAX_W if bl_pct else 0

            # 电池
            bat = read_battery()

            # 温度
            temps = read_temps()

            # 总功耗
            total = None
            if rapl.get("psys") and rapl["psys"] > 0:
                total = rapl["psys"]
            elif rapl.get("pkg") and rapl["pkg"] > 0:
                total = rapl["pkg"]
            elif bat and bat["power"] > 0.1:
                total = bat["power"]

            # 记录
            for k, v in [("pkg", rapl.get("pkg")), ("core", rapl.get("core")),
                         ("uncore", rapl.get("uncore")), ("psys", rapl.get("psys")),
                         ("gpu", gpu["power_est"]), ("screen", screen)]:
                if v is not None:
                    hist[k].append(v)
            if total:
                hist["total"].append(total)

            def avg(k):
                d = hist[k]
                return sum(d) / len(d) if d else 0

            snap = {
                "pkg": rapl.get("pkg"), "core": rapl.get("core"),
                "uncore": rapl.get("uncore"), "psys": rapl.get("psys"),
                "avg_pkg": avg("pkg"), "avg_core": avg("core"),
                "avg_uncore": avg("uncore"), "avg_psys": avg("psys"),
                "gpu": gpu["power_est"], "avg_gpu": avg("gpu"),
                "gpu_freq": gpu["freq"], "gpu_fmax": gpu["freq_max"],
                "gpu_busy": gpu["busy"],
                "screen": screen, "avg_screen": avg("screen"),
                "bl_pct": bl_pct,
                "total": total, "avg_total": avg("total"),
                "cpu_util": util, "avg_freq": avg_f,
                "bat": bat, "bat_discharging": bat and bat["power"] > 0.1,
                "temp_cpu": temps.get("cpu"), "temp_max": temps.get("cpu_max"),
                "dt_ms": dt * 1000, "is_root": is_root,
                "psys_ok": rapl.get("psys") is not None and rapl.get("psys", 0) > 0,
                "pkg_ok": rapl.get("pkg") is not None and rapl.get("pkg", 0) > 0,
            }

            sys.stdout.write(render(snap))
            sys.stdout.flush()

            prev_rapl = curr_rapl
            prev_stat = curr_stat
            prev_t = now
            elapsed = time.monotonic() - now
            time.sleep(max(0.05, INTERVAL - elapsed))
    except (KeyboardInterrupt, SystemExit):
        pass
    finally:
        print(ANSI.SHOW + ANSI.CLEAR, end="", flush=True)

if __name__ == "__main__":
    main()
