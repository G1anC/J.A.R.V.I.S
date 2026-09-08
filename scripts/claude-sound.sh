#!/bin/bash
# Detached playback for Claude Code hooks: a hook that blocks stalls the session.
set -euo pipefail

case "${1:-}" in
    start)    cue=startup ;;
    done)     cue=finished ;;
    question) cue=question ;;
    *) echo "usage: ${0##*/} start|done|question" >&2; exit 2 ;;
esac

path="${CLAUDE_SOUND_DIR:-$HOME/.config/claude/sounds}/$cue.mp3"
[ -r "$path" ] || exit 0
command -v mpv >/dev/null || exit 0

setsid mpv --no-video --really-quiet --volume=70 "$path" >/dev/null 2>&1 &
