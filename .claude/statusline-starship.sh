#!/bin/bash
input=$(cat)
export STATUSLINE_MODEL=$(echo "$input" | jq -r '.model.display_name // ""' | sed 's/Claude //')
export STATUSLINE_COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' | xargs printf '%.2f')
export STATUSLINE_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // env.HOME')

flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
if [ -f "$flag" ] && [ ! -L "$flag" ]; then
  m=$(head -c64 "$flag" | tr -d '\n\r' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
  case "$m" in off|lite|full|ultra|wenyan*|commit|review|compress)
    export STATUSLINE_CAVEMAN=$(echo "$m" | tr '[:lower:]' '[:upper:]');; esac
fi

sf="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-statusline-suffix"
if [ -f "$sf" ] && [ ! -L "$sf" ]; then
  export STATUSLINE_SAVINGS=$(head -c64 "$sf" | tr -d '\000-\037' | awk '{print $NF}')
fi

cd "$current_dir" 2>/dev/null || true
STARSHIP_SHELL=bash starship prompt --profile statusline -w "$((${COLUMNS:-80} - 4))" 2>/dev/null | sed 's/\\\[//g; s/\\\]//g; s/\\\$/$/'
