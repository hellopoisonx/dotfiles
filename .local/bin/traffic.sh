#!/bin/bash
seq=""
to_human_readable() {
    t=$1
    units=("B" "KB" "MB" "GB")
    count=0
    while [ "$t" -ge 1024 ] && [ $count -lt 3 ]; do
        t=$((t / 1024))
        count=$((count + 1))
    done
    echo "$t ${units[$count]}/s"
}

calc() {
    net_data=$(grep 'wlp3s0' /proc/net/dev | awk '{print $2, $10}')
    IFS=' ' read -r down up <<< "$net_data"

    if [ -z "$prev_up" ]; then
        prev_up=$up
    fi
    if [ -z "$prev_down" ]; then
        prev_down=$down
    fi

    upload_speed=$((up - prev_up))
    download_speed=$((down - prev_down))

    prev_up=$up
    prev_down=$down

    _up=$(printf "%8s" "$(to_human_readable "$upload_speed")")
    _down=$(printf "%8s" "$(to_human_readable "$download_speed")")

    echo "$seq[4;48;5;69m$seq[4;38;5;18m: $_up $seq[0m$seq[4;48;5;93m$seq[4;38;5;18m:$_down $seq[0m"
}

outputFifo=$1
while true; do
    calc > "$outputFifo"
    sleep 1
done
