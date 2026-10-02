#!/usr/bin/env bash
set +e
emit() { printf 'Kernel\t%s\t%s\t%s\t%s\n' "$1" "$3" "$4" "$5"; }

if [ -r /proc/uptime ]; then
  seconds="$(awk '{print int($1)}' /proc/uptime 2>/dev/null)"
  days=$((seconds / 86400)); hours=$(((seconds % 86400) / 3600)); minutes=$(((seconds % 3600) / 60))
  emit ok uptime "Uptime" "${days}d ${hours}h ${minutes}m" "/proc/uptime"
else emit info uptime "Uptime" "Unavailable" "/proc/uptime not readable"; fi

if [ -r /proc/loadavg ]; then emit ok load "Load average" "$(awk '{print $1", "$2", "$3}' /proc/loadavg)" "/proc/loadavg"; else emit info load "Load average" "Unavailable" "/proc/loadavg not readable"; fi

if command -v dmesg >/dev/null 2>&1; then
  errors="$(dmesg --level=err,crit,alert,emerg --notime 2>/dev/null | tail -3)"
  [ -n "$errors" ] && emit warn errors "Recent kernel errors" "Present" "dmesg returned recent errors" || emit ok errors "Recent kernel errors" "None found" "dmesg"
else emit info errors "Recent kernel errors" "Not checked" "dmesg is not installed or not permitted"; fi
