#!/usr/bin/env bash
set +e
emit() { printf 'Hardware\t%s\t%s\t%s\t%s\n' "$1" "$3" "$4" "$5"; }

cpu="$(awk -F: '/model name|Hardware/ {gsub(/^ +/,"",$2); print $2; exit}' /proc/cpuinfo 2>/dev/null)"
if [ -n "$cpu" ]; then emit ok cpu "Processor" "$cpu" "/proc/cpuinfo"; else emit info cpu "Processor" "Not detected" "/proc/cpuinfo unavailable"; fi

if command -v free >/dev/null 2>&1; then
  ram="$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}')"
  [ -n "$ram" ] && emit ok memory "Memory" "$ram" "free" || emit info memory "Memory" "Not detected" "free returned no data"
else emit info memory "Memory" "Unavailable" "free is not installed"; fi

gpu=""
if command -v lspci >/dev/null 2>&1; then gpu="$(lspci 2>/dev/null | awk -F': ' '/VGA compatible controller|3D controller|Display controller/ {print $2; exit}')"; fi
if [ -n "$gpu" ]; then emit ok graphics "Graphics" "$gpu" "lspci"; else emit info graphics "Graphics" "Not detected" "Install pciutils for PCI graphics details"; fi

driver=""
if command -v lspci >/dev/null 2>&1; then driver="$(lspci -k 2>/dev/null | awk -F': ' '/Kernel driver in use:/ {print $2; exit}')"; fi
if [ -n "$driver" ]; then emit ok graphics-driver "Graphics driver" "$driver" "lspci"; else emit info graphics-driver "Graphics driver" "Not detected" "Kernel driver data unavailable"; fi

if command -v sensors >/dev/null 2>&1; then
  temp="$(sensors 2>/dev/null | awk '/Core 0|Package id 0|Tctl/ {print $0; exit}')"
  [ -n "$temp" ] && emit ok sensors "Temperature sensors" "$temp" "sensors" || emit info sensors "Temperature sensors" "No readings" "sensors returned no matching reading"
else emit info sensors "Temperature sensors" "Unavailable" "lm-sensors is not installed"; fi
