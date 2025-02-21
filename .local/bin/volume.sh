#!/bin/bash
seq=""
calc() {
    if [ "$(pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: yes" ]; then
        echo "$seq[4;48;5;124m$seq[4;38;5;18m  $seq[0m"
    else
        vol=$(pactl get-sink-volume @DEFAULT_SINK@ \
            | grep -P '[0-9]?[0-9]?[0-9]\%' --only-matching \
            | head -n 1 \
            | grep -P '[0-9]?[0-9]?[0-9]' --only-matching)
        if [ "$vol" -lt 20 ]; then
            echo "$seq[4;48;5;93m$seq[4;38;5;18m :$vol% $seq[0m"
        else
            echo "$seq[4;48;5;93m$seq[4;38;5;18m :$vol% $seq[0m"
        fi
    fi
}

while true; do
    calc > "$1"
    sleep 1
done
