#!/usr/bin/env bash
set +e
emit() { printf 'Network\t%s\t%s\t%s\t%s\n' "$1" "$3" "$4" "$5"; }

if command -v ip >/dev/null 2>&1; then
  iface="$(ip -o link show up 2>/dev/null | awk -F': ' '$2 !~ /^lo([:@]|$)/ {print $2; exit}')"
  [ -n "$iface" ] && emit ok interface "Network interface" "$iface" "ip link" || emit warn interface "Network interface" "No active interface" "ip link"
  gateway="$(ip route show default 2>/dev/null | awk '{print $3; exit}')"
  [ -n "$gateway" ] && emit ok gateway "Default gateway" "$gateway" "ip route" || emit warn gateway "Default gateway" "Not found" "ip route"
else
  emit info interface "Network interface" "Unavailable" "ip is not installed"
  emit info gateway "Default gateway" "Unavailable" "ip is not installed"
fi

if command -v getent >/dev/null 2>&1; then
  if getent hosts example.com >/dev/null 2>&1; then emit ok dns "DNS lookup" "Working" "getent example.com"; else emit warn dns "DNS lookup" "Failed" "Could not resolve example.com"; fi
else emit info dns "DNS lookup" "Unavailable" "getent is not installed"; fi

if command -v curl >/dev/null 2>&1; then
  if curl -Is --connect-timeout 3 --max-time 5 https://example.com >/dev/null 2>&1; then emit ok internet "Internet" "Reachable" "HTTPS request to example.com"; else emit warn internet "Internet" "Not reachable" "HTTPS request failed"; fi
else emit info internet "Internet" "Not checked" "curl is not installed"; fi
