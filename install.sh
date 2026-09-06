#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$HOME/.agents"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CRUSH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/crush"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.jarvis-backups/$STAMP"

log()  { printf '  %s\n' "$*"; }
warn() { printf '  ! %s\n' "$*" >&2; }
die()  { printf '  x %s\n' "$*" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || die "jq is required (statusline and startup hook both parse JSON). Install it, then re-run."

back_up() {
    local dest="$1" rel="$2"
    [[ -e "$dest" || -L "$dest" ]] || return 0
    mkdir -p "$(dirname "$BACKUP/$rel")"
    cp -RL "$dest" "$BACKUP/$rel"
    log "backed up  $rel"
}

printf '\nJ.A.R.V.I.S.\n\n'
log "policy:  $AGENTS_DIR"
log "claude:  $CLAUDE_DIR"
log "crush:   $CRUSH_DIR"
printf '\n'

MYCELIUM_DIR="$HOME/.mycelium"

# AGENTS.md and skills/ are built from mycelium/, never edited directly.
back_up "$MYCELIUM_DIR/rules" "mycelium/rules"
mkdir -p "$MYCELIUM_DIR/rules" "$MYCELIUM_DIR/skills"
cp "$SRC"/mycelium/rules/*.md "$MYCELIUM_DIR/rules/"
cp "$SRC"/mycelium/skills/*.md "$MYCELIUM_DIR/skills/"
for extra in references scripts; do
    if [[ -d "$SRC/mycelium/skills/$extra" ]]; then
        cp -R "$SRC/mycelium/skills/$extra" "$MYCELIUM_DIR/skills/"
    fi
done
log "installed  ~/.mycelium/rules and ~/.mycelium/skills"

mkdir -p "$AGENTS_DIR"
if [[ -e "$SRC/caveman.md" && "$SRC" != "$AGENTS_DIR" ]]; then
    cp "$SRC/caveman.md" "$AGENTS_DIR/"
fi

if command -v mycelium >/dev/null 2>&1; then
    mycelium install agents >/dev/null
    log "generated  ~/.agents/AGENTS.md and ~/.agents/skills (mycelium)"
else
    # Same concatenation mycelium does, so the config works without it.
    cat "$SRC"/mycelium/rules/*.md > "$AGENTS_DIR/AGENTS.md"
    for f in "$SRC"/mycelium/skills/*.md; do
        name="$(basename "$f" .md)"
        mkdir -p "$AGENTS_DIR/skills/$name"
        cp "$f" "$AGENTS_DIR/skills/$name/SKILL.md"
    done
    log "generated  ~/.agents/AGENTS.md and ~/.agents/skills (no mycelium, plain concat)"
    warn "mycelium is not installed, so nothing will regenerate these on change."
fi

# Claude Code reads CLAUDE.md; point it at the one policy file instead of copying it.
mkdir -p "$CLAUDE_DIR/scripts"
back_up "$CLAUDE_DIR/CLAUDE.md" "claude/CLAUDE.md"
ln -sfn "$AGENTS_DIR/AGENTS.md" "$CLAUDE_DIR/CLAUDE.md"
log "linked     ~/.claude/CLAUDE.md -> ~/.agents/AGENTS.md"

back_up "$CLAUDE_DIR/settings.json" "claude/settings.json"
cp "$SRC/claude/settings.json" "$CLAUDE_DIR/settings.json"
log "installed  ~/.claude/settings.json"

for f in "$SRC"/claude/scripts/*.sh; do
    name="$(basename "$f")"
    back_up "$CLAUDE_DIR/scripts/$name" "claude/scripts/$name"
    cp "$f" "$CLAUDE_DIR/scripts/$name"
    chmod +x "$CLAUDE_DIR/scripts/$name"
    log "installed  ~/.claude/scripts/$name"
done

# Crush takes absolute paths only, so bake $HOME in rather than shipping a literal.
mkdir -p "$CRUSH_DIR"
back_up "$CRUSH_DIR/crush.json" "crush/crush.json"
sed "s#__HOME__#$HOME#g" "$SRC/crush/crush.json" > "$CRUSH_DIR/crush.json"
log "installed  $CRUSH_DIR/crush.json"

printf '\n'
[[ -d "$BACKUP" ]] && log "replaced files saved to $BACKUP"
warn "settings.json and crush.json are replaced wholesale, not merged."
warn "Had your own hooks, permissions, MCP servers or providers? Merge them back from the backup."
printf '\n'
log "crush.json expects OPENROUTER_API_KEY in the environment. It stores no key itself."
log "Claude Code: run /plugin once so the caveman marketplace syncs."
log "Then edit the User Profile and Infrastructure blocks in AGENTS.md so they are yours."
printf '\n'
