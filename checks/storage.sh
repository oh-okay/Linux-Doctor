#!/usr/bin/env bash
set +e
emit() { printf 'Storage\t%s\t%s\t%s\t%s\n' "$1" "$3" "$4" "$5"; }
if ! command -v df >/dev/null 2>&1; then emit info unavailable "Storage" "Unavailable" "df is not installed"; exit 0; fi

df -P -x tmpfs -x devtmpfs -x squashfs 2>/dev/null | awk 'NR > 1 && $6 ~ /^\// {gsub(/%/,"",$5); print $6 "\t" $5 "\t" $4}' | while IFS=$'\t' read -r mount used available; do
  [ -z "$mount" ] && continue
  if [ "$used" -ge 90 ] 2>/dev/null; then status=warn; detail="Only ${available} available"
  elif [ "$used" -ge 80 ] 2>/dev/null; then status=info; detail="Worth keeping an eye on"
  else status=ok; detail="${available} available"; fi
  emit "$status" filesystem "$mount" "${used}% used" "$detail"
done
