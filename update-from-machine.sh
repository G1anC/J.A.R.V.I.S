#!/usr/bin/env bash
set -euo pipefail

# Pulls this machine's live sources back into the repo. The opposite of install.sh.
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYCELIUM_DIR="$HOME/.mycelium"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

cp "$MYCELIUM_DIR"/rules/*.md "$SRC/mycelium/rules/"
cp "$MYCELIUM_DIR"/skills/*.md "$SRC/mycelium/skills/"
for extra in references scripts; do
    if [[ -d "$MYCELIUM_DIR/skills/$extra" ]]; then
        cp -R "$MYCELIUM_DIR/skills/$extra" "$SRC/mycelium/skills/"
    fi
done
cp "$CLAUDE_DIR/scripts"/*.sh "$SRC/claude/scripts/"
if [[ "$SRC" != "$HOME/.agents" && -e "$HOME/.agents/caveman.md" ]]; then
    cp "$HOME/.agents/caveman.md" "$SRC/caveman.md"
fi

# settings.json is filtered, not copied: autoMode and permissions are machine-local.
python3 - "$CLAUDE_DIR/settings.json" "$SRC/claude/settings.json" <<'PY'
import collections, json, sys
src, dest = sys.argv[1], sys.argv[2]
d = json.load(open(src), object_pairs_hook=collections.OrderedDict)
for k in ("autoMode", "permissions"):
    d.pop(k, None)
json.dump(d, open(dest, "w"), indent=2)
open(dest, "a").write("\n")
PY

sed "s#$HOME#__HOME__#g" "${XDG_CONFIG_HOME:-$HOME/.config}/crush/crush.json" > "$SRC/crush/crush.json"

printf '\n  Pulled. Ignored paths stay out on their own; review with git diff.\n\n'
git -C "$SRC" status --short
