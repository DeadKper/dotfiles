#!/bin/bash
input=$(cat)
export STATUSLINE_MODEL=$(echo "$input" | jq -r '.model.display_name // ""' | sed 's/Claude //')
export STATUSLINE_COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' | xargs printf '%.2f')
export STATUSLINE_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // env.HOME')

caveman_active="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
if [ -f "$caveman_active" ] && [ ! -L "$caveman_active" ]; then
  caveman_mode=$(head -c64 "$caveman_active" | tr -d '\n\r' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
  case "$caveman_mode" in off|lite|full|ultra|wenyan*|commit|review|compress)
    export STATUSLINE_CAVEMAN=$(echo "$caveman_mode" | tr '[:lower:]' '[:upper:]');; esac
fi

caveman_suffix="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-statusline-suffix"
if [ -f "$caveman_suffix" ] && [ ! -L "$caveman_suffix" ]; then
  export STATUSLINE_SAVINGS=$(head -c64 "$caveman_suffix" | tr -d '\000-\037' | awk '{print $NF}')
fi

cd "$current_dir" 2>/dev/null || true
statusline=$(STARSHIP_SHELL=bash starship prompt --profile statusline -w "$((${COLUMNS:-80} - 4))" 2>/dev/null | sed 's/\\\[//g; s/\\\]//g')
original_size="${#statusline}"
statusline=$(sed 's/\\\$/$/g' <<< "$statusline")
extra=$((original_size - ${#statusline}))
if [ "$extra" -gt 0 ]; then
  statusline=$(sed -E "s/(\x1b\[[0-9;]*m)( {2,})/\1$(printf '%*s' "$extra" '')\2/" <<< "$statusline")
fi
printf '%s\n' "$statusline"
