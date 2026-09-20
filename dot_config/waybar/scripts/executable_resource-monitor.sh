#!/bin/bash
# ── Resource Monitor for Waybar ──────────────────────────────
# Outputs JSON for custom/resource: CPU, Memory, GPU, and RAPL psys power

# === CPU: compute delta between Waybar interval runs ===
CPU_FILE="/tmp/waybar-resource-cpu.${UID}"

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
cur_idle=$((idle + iowait))
cur_total=$((user + nice + system + cur_idle + irq + softirq + steal))

if [ -f "$CPU_FILE" ]; then
    read -r prev_idle prev_total < "$CPU_FILE"
    d_idle=$((cur_idle - prev_idle))
    d_total=$((cur_total - prev_total))
    if [ "$d_total" -gt 0 ]; then
        cpu=$((100 - (d_idle * 100 / d_total)))
    else
        cpu=0
    fi
else
    cpu=0
fi
echo "$cur_idle $cur_total" > "$CPU_FILE"

# === Memory ===
mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
mem=$((100 - (mem_avail * 100 / mem_total)))

# === GPU: max engine busy across all engines ===
gpu_raw=$(intel_gpu_top -J -s 200 -n 1 2>/dev/null | \
    jq -r '(if type == "array" then .[0] else . end)
        | .engines // {}
        | [.[].busy // 0]
        | max // 0
        | floor' 2>/dev/null)
gpu=${gpu_raw:-"N/A"}

# === System power: RAPL psys (platform total, not battery discharge) ===
POWER_FILE="/tmp/waybar-resource-power.${UID}"
power="N/A"

for zone in /sys/class/powercap/intel-rapl:*; do
    [ -r "$zone/name" ] || continue
    [ "$(<"$zone/name")" = "psys" ] || continue
    [ -r "$zone/energy_uj" ] || continue

    energy=$(<"$zone/energy_uj")
    now_ns=$(date +%s%N)
    max_energy=$(<"$zone/max_energy_range_uj")

    if [[ "$energy" =~ ^[0-9]+$ && "$now_ns" =~ ^[0-9]+$ && "$max_energy" =~ ^[0-9]+$ ]]; then
        if [ -f "$POWER_FILE" ]; then
            read -r prev_energy prev_ns < "$POWER_FILE"
            if [[ "$prev_energy" =~ ^[0-9]+$ && "$prev_ns" =~ ^[0-9]+$ ]]; then
                elapsed_ns=$((now_ns - prev_ns))
                if [ "$energy" -ge "$prev_energy" ]; then
                    energy_delta=$((energy - prev_energy))
                else
                    energy_delta=$((max_energy - prev_energy + energy))
                fi

                if [ "$elapsed_ns" -gt 0 ]; then
                    power=$(awk -v energy_uj="$energy_delta" -v elapsed_ns="$elapsed_ns" \
                        'BEGIN { printf "%.1f", energy_uj * 1000 / elapsed_ns }')
                fi
            fi
        fi
        printf '%s %s\n' "$energy" "$now_ns" > "$POWER_FILE"
    fi
    break
done

# === Determine CSS class by worst metric ===
cls=""
max_val=0
for v in "$cpu" "$mem" "$gpu"; do
    case "$v" in ''|*[!0-9]*) continue;; esac
    [ "$v" -gt "$max_val" ] && max_val="$v"
done
if [ "$max_val" -ge 90 ]; then cls="critical"
elif [ "$max_val" -ge 80 ]; then cls="warning"
elif [ "$max_val" -ge 60 ]; then cls="moderate"
fi

# === Output (jq handles all escaping) ===
if [ "$power" = "N/A" ]; then
    power_text="$power"
    power_tooltip="$power"
else
    power_text="${power}W"
    power_tooltip="${power} W"
fi

text=" ${cpu}%   ${mem}%   ${gpu}%   ${power_text}"
tooltip=$(printf "CPU:          %s%%\nMemory:       %s%%\nGPU:          %s%%\nSystem power: %s (RAPL psys)" \
    "$cpu" "$mem" "$gpu" "$power_tooltip")

jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$cls" \
    '{text: $text, tooltip: $tooltip, class: $class}'
