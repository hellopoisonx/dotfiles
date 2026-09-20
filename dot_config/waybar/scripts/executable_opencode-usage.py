#!/usr/bin/env python3
"""OpenCode Go 套餐余量监控 Waybar 模块（多账号）

从同目录 opencode-usage.json 读取账号列表，调用 opencode.ai 的 Convex
RPC 端点获取每个账号的 5h/本周/本月用量，输出 waybar custom 模块 JSON:
    { "text": "...", "tooltip": "...", "class": "ok|warning|critical|auth" }

纯 Python 标准库实现，无第三方依赖。

配置文件结构（opencode-usage.json）:
{
  "accounts": [
    {
      "name": "A1",
      "cookies": "oc_locale=zh; auth=Fe26.2**...",
      "workspace_id": "wrk_xxx",
      "server_id": "...",           // 可选，缺省用默认值
      "server_instance": "server-fn:3",  // 可选
      "plan_monthly_limit": null     // 可选，月额度上限（美元），仅当 API 不返回 limit 时使用
    }
  ]
}
"""

import json
import os
import re
import sys
import urllib.parse
import urllib.request
import urllib.error
from datetime import datetime, timedelta

CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "opencode-usage.json")

# README 默认值（可能随部署变更，可在账号配置中覆盖）
DEFAULT_SERVER_ID = "c7389bd0e731f80f49593e5ee53835475f4e28594dd6bd83eb229bab753498cd"
DEFAULT_SERVER_INSTANCE = "server-fn:3"


class AuthExpiredError(Exception):
    pass


# ── Convex JS 响应 → JSON ──────────────────────────────────────────

def _js_to_json(js_str):
    s = js_str
    s = re.sub(r'!0(?=[,}:])', 'true', s)
    s = re.sub(r'!1(?=[,}:])', 'false', s)
    s = re.sub(r'([a-zA-Z_$][\w$]*)(?=\s*:)', r'"\1"', s)
    s = re.sub(r'\$R\[\d+\]=', '', s)
    s = re.sub(r'\$R\[\d+\]', 'null', s)
    return json.loads(s)


def _parse_convex_response(raw):
    if "location" in raw and ("/auth/authorize" in raw or "/login" in raw):
        raise AuthExpiredError()
    m = re.search(r'\$R\[0\]=(.+)', raw)
    if m:
        val = m.group(1)
        val = re.sub(r'\)\(.*$', '', val)
        val = val.rstrip(')')
        try:
            return _js_to_json(val)
        except Exception:
            pass
    for m in re.finditer(r'(\{.*\}|\[.*\])', raw):
        try:
            return json.loads(m.group(0))
        except json.JSONDecodeError:
            continue
    raise ValueError(f"无法解析 Convex 响应: {raw[:200]}")


# ── API 请求 ───────────────────────────────────────────────────────

def fetch_usage(account):
    """返回 {period: {used, limit, resetInSec}} 或抛 AuthExpiredError / 其他异常"""
    server_id = account.get("server_id") or DEFAULT_SERVER_ID
    server_instance = account.get("server_instance") or DEFAULT_SERVER_INSTANCE
    args = {
        "t": {"t": 9, "i": 0, "l": 1, "a": [{"t": 1, "s": account["workspace_id"]}], "o": 0},
        "f": 31, "m": [],
    }
    enc = urllib.parse.quote(json.dumps(args, separators=(",", ":")))
    url = f"https://opencode.ai/_server?id={server_id}&args={enc}"
    headers = {
        "accept": "*/*",
        "accept-language": "zh-CN,zh;q=0.9",
        "cookie": account["cookies"],
        "referer": f"https://opencode.ai/workspace/{account['workspace_id']}/usage",
        "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36",
        "x-server-id": server_id,
        "x-server-instance": server_instance,
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
    }
    req = urllib.request.Request(url, headers=headers)
    try:
        r = urllib.request.urlopen(req, timeout=15)
    except urllib.error.HTTPError as e:
        if e.code in (401, 403):
            raise AuthExpiredError()
        raise
    raw = r.read().decode("utf-8", "replace")
    if not raw.strip():
        raise ValueError("空响应")
    ct = r.headers.get("content-type", "")
    if "javascript" in ct or raw.startswith(";"):
        data = _parse_convex_response(raw)
    else:
        try:
            data = json.loads(raw)
        except json.JSONDecodeError:
            raise ValueError(f"非 JSON 响应: {raw[:200]}")
    return parse_usage(data, account.get("plan_monthly_limit"))


PERIOD_MAP = {
    "rollingUsage": "5h", "hourly": "5h", "5h": "5h",
    "weeklyUsage": "weekly", "weekly": "weekly", "week": "weekly",
    "monthlyUsage": "monthly", "monthly": "monthly", "month": "monthly",
}


def parse_usage(data, fallback_limit=None):
    if isinstance(data, dict) and "value" in data:
        data = data["value"]
    results = {}
    if not isinstance(data, dict):
        return results
    for src_key, period in PERIOD_MAP.items():
        entry = data.get(src_key)
        if isinstance(entry, dict):
            used = None
            for k in ("cost", "amount", "usagePercent", "usage"):
                v = entry.get(k)
                if v is not None:
                    used = v
                    break
            reset = entry.get("resetInSec")
            limit = (entry.get("limit") or entry.get("max") or
                     entry.get("quota") or entry.get("budget") or entry.get("total"))
            if used is not None:
                results[period] = {"used": used, "limit": limit, "resetInSec": reset}
    if fallback_limit:
        for p in results:
            if results[p]["limit"] is None and p in ("monthly", "total"):
                results[p]["limit"] = fallback_limit
    return results


# ── 显示与格式化 ───────────────────────────────────────────────────

def used_to_pct(entry):
    """used 可能是金额（有 limit 时）或已是百分比（无 limit 时）"""
    used = entry.get("used")
    limit = entry.get("limit")
    if used is None:
        return None
    if limit:
        try:
            return float(used) / float(limit) * 100.0
        except (TypeError, ValueError, ZeroDivisionError):
            return None
    try:
        return float(used)
    except (TypeError, ValueError):
        return None


def fmt_reset(secs):
    if secs is None:
        return ""
    try:
        secs = int(secs)
    except (TypeError, ValueError):
        return ""
    if secs <= 0:
        return "已重置"
    if secs < 86400:
        h, m, s = secs // 3600, (secs % 3600) // 60, secs % 60
        return f"{h:02d}:{m:02d}:{s:02d}"
    dt = datetime.now() + timedelta(seconds=secs)
    return dt.strftime("%m-%d %H:%M")


def step_emoji(hourly_entry):
    """5h 步调 emoji：😊 安全 / 😐 正常 / 😰 超支"""
    if not hourly_entry:
        return "😊"
    pct = used_to_pct(hourly_entry)
    reset = hourly_entry.get("resetInSec")
    if pct is None or reset is None:
        return "😊"
    try:
        reset = float(reset)
    except (TypeError, ValueError):
        return "😊"
    elapsed_ratio = 1 - reset / 18000.0  # 18000s = 5h
    if elapsed_ratio <= 0:
        return "😊"
    step_ratio = pct / (elapsed_ratio * 100.0)
    if step_ratio < 0.85:
        return "😊"
    elif step_ratio <= 1.30:
        return "😐"
    else:
        return "😰"


def class_for_pct(pct):
    if pct is None:
        return "ok"
    if pct >= 80:
        return "critical"
    if pct >= 50:
        return "warning"
    return "ok"


def fmt_money(pct, entry):
    """若 limit 存在，用 used/limit 显示金额；否则仅显示百分比"""
    used = entry.get("used")
    limit = entry.get("limit")
    if limit and used is not None:
        try:
            return f"{float(used):.2f}/{float(limit):.2f}"
        except (TypeError, ValueError):
            pass
    if pct is not None:
        return f"{pct:.0f}%"
    return "--"


def process_account(account):
    """返回 (status, parsed, error_msg)
    status: "ok" | "auth" | "error"
    parsed: dict[period -> entry] or None
    """
    try:
        parsed = fetch_usage(account)
        return "ok", parsed, None
    except AuthExpiredError:
        return "auth", None, "Cookie 过期"
    except Exception as e:
        msg = str(e)[:80]
        return "error", None, msg


def build_output(accounts):
    parts_text = []     # 状态栏文本片段
    tooltip_lines = ["<b>OpenCode Go 余量</b>", ""]
    global_max_pct = 0.0
    has_auth_expired = False

    for acc in accounts:
        name = acc.get("name", "?")
        status, parsed, err = process_account(acc)

        if status != "ok":
            if status == "auth":
                has_auth_expired = True
                parts_text.append(f"{name}:🔒")
                tooltip_lines.append(
                    f"<b>[{name}]</b> <span color='#f38ba8'>🔒 Cookie 过期</span>"
                )
                tooltip_lines.append(
                    f"<span size='smaller' color='#6c7086'>更新 opencode-usage.json 中的 cookies 字段</span>"
                )
            else:
                parts_text.append(f"{name}:⚠")
                tooltip_lines.append(
                    f"<b>[{name}]</b> <span color='#fab387'>⚠ 请求失败</span>"
                )
                tooltip_lines.append(
                    f"<span size='smaller' color='#6c7086'>{err}</span>"
                )
            tooltip_lines.append("")
            continue

        # 5h/weekly/monthly 三时段
        hourly = parsed.get("5h")
        weekly = parsed.get("weekly")
        monthly = parsed.get("monthly")

        # 取三时段最高百分比作为该账号显示
        pcts = {}
        for k, e in (("5h", hourly), ("weekly", weekly), ("monthly", monthly)):
            pcts[k] = used_to_pct(e) if e else None

        candidates = [p for p in pcts.values() if p is not None]
        best_pct = max(candidates) if candidates else None

        if best_pct is not None:
            global_max_pct = max(global_max_pct, best_pct)
            parts_text.append(f"{name}:{best_pct:.0f}%")
        else:
            parts_text.append(f"{name}:--")

        # tooltip 三行
        tooltip_lines.append(f"<b>[{name}]</b>")
        for label, key, entry in (("5h", "5h", hourly),
                                  ("本周", "weekly", weekly),
                                  ("本月", "monthly", monthly)):
            if not entry:
                tooltip_lines.append(f"  {label}: <span color='#6c7086'>--</span>")
                continue
            p = pcts[key]
            money = fmt_money(p, entry)
            reset = fmt_reset(entry.get("resetInSec"))
            color = "#a6e3a1" if (p is not None and p < 50) else \
                    "#f9e2af" if (p is not None and p < 80) else "#f38ba8"
            pct_str = f"{p:.0f}%" if p is not None else "--"
            line = f"  {label}: <span color='{color}'>{pct_str}</span>"
            line += f"  <span size='smaller' color='#a6adc8'>({money})</span>"
            if reset:
                line += f"  <span size='smaller' color='#6c7086'>→ {reset}</span>"
            if key == "5h":
                line += f" {step_emoji(entry)}"
            tooltip_lines.append(line)
        tooltip_lines.append("")

    # 全局 class
    if has_auth_expired:
        cls = "auth"
    else:
        cls = class_for_pct(global_max_pct if global_max_pct else 0.0)

    mood_emoji = "😰" if global_max_pct >= 80 else "😐" if global_max_pct >= 50 else "😊"
    text = "  ".join(parts_text) if parts_text else "opencode:--"
    if not has_auth_expired:
        text = f"{text}  {mood_emoji}"
    tooltip = "\n".join(tooltip_lines).rstrip()

    return {"text": text, "tooltip": tooltip, "class": cls}


def main():
    if not os.path.exists(CONFIG_PATH):
        print(json.dumps({
            "text": "opencode:🔒",
            "tooltip": f"未找到配置文件\n{CONFIG_PATH}\n请复制 opencode-usage.json.example 并填入账号信息",
            "class": "auth",
        }, ensure_ascii=False))
        return

    try:
        with open(CONFIG_PATH, "r", encoding="utf-8") as f:
            cfg = json.load(f)
    except Exception as e:
        print(json.dumps({
            "text": "opencode:⚠",
            "tooltip": f"配置解析失败: {e}",
            "class": "error",
        }, ensure_ascii=False))
        return

    accounts = cfg.get("accounts") or []
    if not accounts:
        print(json.dumps({
            "text": "opencode:--",
            "tooltip": "accounts 为空，请在 opencode-usage.json 中添加账号",
            "class": "error",
        }, ensure_ascii=False))
        return

    try:
        out = build_output(accounts)
    except Exception as e:
        out = {
            "text": "opencode:⚠",
            "tooltip": f"内部错误: {e}",
            "class": "error",
        }
    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    main()