#!/usr/bin/bash
lscpu -e

for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo -n "$(basename $cpu): "
    cat $cpu/cpufreq/cpuinfo_max_freq 2>/dev/null || echo "N/A"
done
