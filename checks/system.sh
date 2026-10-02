#!/usr/bin/env bash
# Read-only system facts. Output: section, status, label, value, detail.
set +e
emit() { printf 'System\t%s\t%s\t%s\t%s\n' "$1" "$3" "$4" "$5"; }

os_name="Unknown Linux"
os_version=""
if [ -r /etc/os-release ]; then
  . /etc/os-release
  os_name="${PRETTY_NAME:-${NAME:-Unknown Linux}}"
  os_version="${VERSION_ID:-}"
fi
emit ok os "Operating system" "$os_name${os_version:+ ($os_version)}" "Detected from /etc/os-release"
emit ok architecture "Architecture" "$(uname -m 2>/dev/null || printf unknown)" "Kernel-reported architecture"
emit ok kernel "Kernel" "$(uname -r 2>/dev/null || printf unknown)" "Kernel release"

desktop="${XDG_CURRENT_DESKTOP:-${XDG_SESSION_DESKTOP:-}}"
session="${XDG_SESSION_TYPE:-}"
if [ -n "$desktop" ] || [ -n "$session" ]; then
  emit ok desktop "Desktop session" "${desktop:-Unknown}${session:+ / $session}" "Environment variables"
else
  emit info desktop "Desktop session" "Not detected" "This may be a headless shell"
fi
init="$(ps -p 1 -o comm= 2>/dev/null | tr -d ' ' || true)"
if [ -n "$init" ]; then emit ok init "Init system" "$init" "PID 1"; else emit info init "Init system" "Not detected" "ps unavailable"; fi
