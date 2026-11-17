#!/usr/bin/env bash
# Lekki zapis temperatury i obciążenia laptopa do CSV co 10 s (prośba Adriana 17.11.2026, porównanie po serwisie).
# Kolumny: czas, temp. pakietu CPU (°C), acpitz (°C), NVMe (°C), GPU (°C), GPU (%), load 1m, MHz cpu0,
# licznik dławienia pakietu, workerzy floty, bramki, wdrożenie, zadania mielarki.
export LC_ALL=C
DIR="$HOME/.local/share/hw-monitor/surowe"; mkdir -p "$DIR"
HDR="czas,cpu_c,acpitz_c,nvme_c,gpu_c,gpu_proc,load1,mhz,dlawienie,workerzy,bramki,wdrozenie,mielarka"
rd() { [ -r "$1" ] && awk '{printf "%.1f", $1/1000}' "$1" || echo ""; }
hw() { for d in /sys/class/hwmon/*; do [ "$(cat $d/name 2>/dev/null)" = "$1" ] && echo "$d/temp1_input" && return; done; }
CPU=$(hw coretemp); ACPI=$(hw acpitz); NVME=$(hw nvme)
i=0; gpu=","
while true; do
  if (( i % 3 == 0 )); then gpu=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ' ); [ -n "$gpu" ] || gpu=","; fi
  load=$(cut -d' ' -f1 /proc/loadavg)
  mhz=$(( $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo 0) / 1000 ))
  thr=$(cat /sys/devices/system/cpu/cpu0/thermal_throttle/package_throttle_count 2>/dev/null)
  ps=$(ps -eo args)
  w=$(grep -cE '^[^ ]*claude .*--remote-control studia-flota-' <<<"$ps")
  g=$(grep -c '^bash .*tools/fleet/gates.sh' <<<"$ps")
  dep=$(grep -cE '^node [^ ]*deploy\.mjs' <<<"$ps")
  mp=$(pgrep -f 'worker/worker.js' | head -1); m=0; [ -n "$mp" ] && m=$(pgrep -P "$mp" | wc -l)
  OUT="$DIR/$(date +%F).csv"; [ -s "$OUT" ] || echo "$HDR" > "$OUT"
  echo "$(date -Iseconds),$(rd $CPU),$(rd $ACPI),$(rd $NVME),$gpu,$load,$mhz,$thr,$w,$g,$dep,$m" >> "$OUT"
  i=$((i+1)); sleep 10
done
