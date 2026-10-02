#!/usr/bin/env bash
set +e
emit() { printf 'Services\t%s\t%s\t%s\t%s\n' "$1" "$3" "$4" "$5"; }

if command -v systemctl >/dev/null 2>&1; then
  state="$(systemctl is-system-running 2>/dev/null || true)"
  case "$state" in
    running) emit ok systemd "systemd" "Running normally" "systemctl" ;;
    degraded) emit warn systemd "systemd" "Degraded" "One or more units need attention" ;;
    *) emit info systemd "systemd" "${state:-Unknown}" "systemctl" ;;
  esac
  failed="$(systemctl --failed --no-legend --no-pager 2>/dev/null | awk 'NF {print $1}' | head -10)"
  if [ -n "$failed" ]; then
    while IFS= read -r unit; do [ -n "$unit" ] && emit warn failed-service "$unit" "Failed" "systemctl --failed"; done <<< "$failed"
  else emit ok failed-services "Failed services" "None found" "systemctl --failed"; fi
else emit info systemd "systemd" "Unavailable" "systemctl is not installed"; fi
