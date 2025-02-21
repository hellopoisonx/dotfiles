#!/bin/bash
export light=""
export volume=""
export time=""
export traffic=" "
export mem="󰍛"
export caps_lock="  "
export checkupdate=""

start_time=$(date --iso-8601=seconds)

result_prefix="/tmp/"
light_result="${result_prefix}light_result_$start_time"
volume_result="${result_prefix}volume_result_$start_time"
time_result="${result_prefix}time_result_$start_time"
traffic_result="${result_prefix}traffic_result_$start_time"
mem_result="${result_prefix}mem_result_$start_time"
caps_lock_result="${result_prefix}caps_lock_result_$start_time"
checkupdate_result="/tmp/checkupdate_result"

mkfifo -m=u+wr "$light_result" | exit
mkfifo -m=u+wr "$volume_result" | exit
mkfifo -m=u+wr "$time_result" | exit
mkfifo -m=u+wr "$traffic_result" | exit
mkfifo -m=u+wr "$mem_result" | exit
mkfifo -m=u+wr "$caps_lock_result" | exit

light.sh "$light_result" &
volume.sh "$volume_result" &
time.sh "$time_result" &
traffic.sh "$traffic_result" &
mem.sh "$mem_result" &
caps_lock.sh "$caps_lock_result" &

while xsetroot -name "$caps_lock$checkupdate$traffic$mem$light$volume$time"; do
    light=$(head -n 1 "$light_result")
    traffic=$(head -n 1 "$traffic_result")
    time=$(head -n 1 "$time_result")
    volume=$(head -n 1 "$volume_result")
    mem=$(head -n 1 "$mem_result")
    caps_lock=$(head -n 1 "$caps_lock_result")
    checkupdate=$(head -n 1 "$checkupdate_result")
done
