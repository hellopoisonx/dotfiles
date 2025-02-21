#!/bin/bash
seq=""
path=/tmp/checkupdate_result
echo -n "${seq}[4;48;5;99m${seq}[4;38;5;18m : $(yay -Qu | wc -l) ${seq}[0m" >$path
