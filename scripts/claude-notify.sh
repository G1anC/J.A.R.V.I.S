#!/bin/bash
# Claude Code Notification hook: stdin carries the event as JSON.
set -euo pipefail

payload=$(cat)
message=$(jq -r '.message // "Claude Code"' <<< "$payload")
cwd=$(jq -r '.cwd // ""' <<< "$payload")

title="Claude Code"
[ -n "$cwd" ] && title="${cwd##*/}"

notify-send -a "Claude Code" -u normal "$title" "$message"

bash "$HOME/.agents/scripts/claude-sound.sh" question
