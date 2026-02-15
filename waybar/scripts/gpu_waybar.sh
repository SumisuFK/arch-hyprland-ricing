#!/usr/bin/env bash
set -euo pipefail

GPU_INDEX="${GPU_INDEX:-0}"

# util,temp,mem_used,mem_total,power,fan
line="$(nvidia-smi -i "$GPU_INDEX" \
  --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw,fan.speed \
  --format=csv,noheader,nounits)"

IFS=',' read -r util temp mem_used mem_total power fan <<< "$line"

util="$(echo "$util" | xargs)"
temp="$(echo "$temp" | xargs)"
mem_used="$(echo "$mem_used" | xargs)"
mem_total="$(echo "$mem_total" | xargs)"
power="$(echo "$power" | xargs)"
fan="$(echo "$fan" | xargs)"

# ??, ??? ????? ??????: ?????? ????????
text="${util}"

# ??, ??? ????? ??? ?????????: ??????
tooltip="🌡  GPU Temp: ${temp}°C&#10;󰻠  VRAM: ${mem_used}/${mem_total} MiB&#10;󰉁  Power: ${power} W&#10;󰈐  Fan: ${fan}%"

# ?????? ??? ?????
util_i=$((util))
temp_i=$((temp))
cls="ok"
if (( temp_i >= 80 || util_i >= 90 )); then
  cls="crit"
elif (( temp_i >= 72 || util_i >= 70 )); then
  cls="warn"
fi

# JSON-safe escape ????? python (???????)
json_escape() { python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'; }

printf '{"text":%s,"tooltip":%s,"class":"%s"}\n' \
  "$(printf "%s" "$text" | json_escape)" \
  "$(printf "%s" "$tooltip" | json_escape)" \
  "$cls"