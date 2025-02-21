#!/bin/bash
seq=""
calc() {
  lines=$(grep -e "MemTotal" -e "MemAvailable" /proc/meminfo | awk '{print $2}')
  total=$(echo "$lines" | head -n 1)
  ava=$(echo "$lines" | tail -n 1)
  printf "%5s" "${seq}[4;48;5;60m${seq}[4;38;5;18m 󰍛:$(((total - ava) * 100 / total))% ${seq}[0m"
}

outputFifo=$1
while true; do
  calc >"$outputFifo"
  sleep 1s
done
