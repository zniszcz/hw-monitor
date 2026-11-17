#!/usr/bin/env bash
cd "$HOME/.local/share/hw-monitor" && ./agreguj.sh && git add -A && { git commit -qm "Próbki $(date -Iminutes)" >/dev/null 2>&1; git push -q origin main >/dev/null 2>&1; } || true
