#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // "claude"')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
output_style=$(printf '%s' "$input" | jq -r '.output_style.name // empty')

if [[ -n "$cwd" ]]; then
  if [[ "$cwd" == "$HOME" ]]; then
    short="~"
  elif [[ "$cwd" == "$HOME"/* ]]; then
    short="~/${cwd#$HOME/}"
  else
    short="$cwd"
  fi
else
  short="?"
fi

branch=""
if [[ -n "$cwd" && -d "$cwd" ]]; then
  branch=$(git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null || true)
fi

esc=$'\033'
reset="${esc}[0m"
dim="${esc}[2m"
fg_red="${esc}[38;2;247;118;142m"
fg_orange="${esc}[38;2;255;158;100m"
fg_yellow="${esc}[38;2;224;175;104m"
fg_green="${esc}[38;2;158;206;106m"
fg_cyan="${esc}[38;2;125;207;255m"
fg_blue="${esc}[38;2;122;162;247m"
fg_magenta="${esc}[38;2;187;154;247m"
fg_fg="${esc}[38;2;169;177;214m"
fg_mute="${esc}[38;2;86;95;137m"

sep="${fg_mute} · ${reset}"

out="${fg_magenta}${model}${reset}"
out+="${sep}${fg_blue}${short}${reset}"
[[ -n "$branch" ]] && out+="${sep}${fg_green}${branch}${reset}"
[[ -n "$output_style" && "$output_style" != "default" ]] && out+="${sep}${fg_yellow}${output_style}${reset}"

printf '%s' "$out"
