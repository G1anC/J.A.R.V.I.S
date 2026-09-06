# ~/.agents — shared agent config

Single source of truth for every agent harness.

| File | Role |
|---|---|
| `AGENTS.md` | Base policy: persona, core rules, git/code style, wiki protocol |
| `caveman.md` | Full caveman ruleset, level `full` (regenerate from caveman plugin) |
| `skills/` | Agent Skills (`SKILL.md` folders) |
| `wiki/` | Durable knowledge |

## Wiring

- **Claude Code** — `~/.claude/CLAUDE.md` → symlink to `AGENTS.md`. Caveman comes from the plugin `SessionStart` hook, not `caveman.md`.
- **Crush** — `~/.config/crush/crush.json` sets `options.global_context_paths` to `AGENTS.md` + `caveman.md`, `options.skills_paths` to `~/.agents/skills` and `~/.claude/skills`. Provider keys and model choice stay in `~/.local/share/crush/crush.json`.
- **opencode** — `~/.config/opencode/opencode.jsonc` sets `instructions` to the same two files.

Per-project overrides still work normally: `CLAUDE.md`, `CRUSH.md`/`AGENTS.md`, `.crush.json`.

## Regenerate caveman.md

```sh
node ~/.claude/plugins/cache/caveman/caveman/*/hooks/caveman-activate.js
```

Drop the first `CAVEMAN MODE ACTIVE` line, keep the rest.
