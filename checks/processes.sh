#!/usr/bin/env bash
set +e
emit() { printf 'Processes\t%s\t%s\t%s\t%s\n' "$1" "$3" "$4" "$5"; }

if command -v ps >/dev/null 2>&1; then
  count="$(ps -e --no-headers 2>/dev/null | wc -l | tr -d ' ')"
  emit ok count "Running processes" "$count" "ps"
  top="$(ps -eo comm=,pcpu= --sort=-pcpu 2>/dev/null | awk 'NR==1 {printf "%s (%s%%)", $1, $2}')"
  [ -n "$top" ] && emit info top "Top CPU process" "$top" "ps" || true
else emit info count "Running processes" "Unavailable" "ps is not installed"; fi
