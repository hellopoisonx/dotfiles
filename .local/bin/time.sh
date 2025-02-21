#!/bin/bash
seq=""
while true; do
    echo "$seq[4;48;5;202m$seq[4;38;5;18m :$(date +%Y-%m-%d\ %H:%M:%S) $seq[0m"> "$1"
    sleep 1
done
