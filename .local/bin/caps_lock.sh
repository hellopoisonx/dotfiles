#!/bin/bash
seq=""
while true; do
    status="$(xset -q | sed -n 's/^.*Caps Lock:\s*\(\S*\).*$/\1/p')"
    if [ "$status" == "off" ]; then
        echo "$seq[4;48;5;63m$seq[4;38;5;18m  $seq[0m" > "$1"
    else 
        echo "$seq[4;48;5;160m$seq[4;38;5;18m  $seq[0m" > "$1"
    fi
    sleep 1
done
