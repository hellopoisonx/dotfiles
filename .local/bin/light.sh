#!/bin/bash
seq=""
while true; do
    light=$(light | grep -P '[0-9]?[0-9]?[0-9]' --only-matching | head -n 1)
    echo "$seq[4;48;5;76m$seq[4;38;5;18m :$light $seq[0m" > "$1"
    sleep 1
done
