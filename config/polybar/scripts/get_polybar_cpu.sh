#!/bin/bash

PID=$(pidof polybar)

if [[ -n "$PID" ]]; then
  sum=0
  for i in {1..3}; do
    CPU_USAGE=$(ps -p "$PID" -o %cpu=)
    if [[ -n "$CPU_USAGE" ]]; then
      sum=$(echo "$sum + $CPU_USAGE" | bc)
    fi
    sleep 0.1
  done
  if [[ $(echo "$sum > 0" | bc) -eq 1 ]]; then
    avg=$(echo "scale=2; $sum / 3" | bc)
    printf "%.2f%%\n" "$avg"
  else
    printf "0.00%%\n"
  fi
else
  printf "0.00%%\n"
fi
