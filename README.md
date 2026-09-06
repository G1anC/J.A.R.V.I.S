# J.A.R.V.I.S.

One agent policy, shared by every harness. Claude Code and Crush read the same
`AGENTS.md`, run the same skills, and write to the same wiki.

Two ideas hold it together.

**Caveman by default.** Responses drop articles, filler and hedging while keeping every
technical detail exact. It reads like a smart caveman and costs a fraction of the tokens.
The mode lifts automatically wherever terseness is dangerous: security warnings,
destructive confirmations, ordered instructions, and anything the human will read outside
the terminal.

**A wiki instead of a memory.** Durable knowledge goes in `wiki/`, never in the policy
file. `AGENTS.md` stores the procedure for reading and writing facts, not the facts.
Every non-obvious claim carries provenance, and a superseded claim gets marked rather
than deleted.

## Layout

| Path | Role |
|---|---|
| `mycelium/rules/` | The base policy, in six ordered pieces. Source of `AGENTS.md` |
| `mycelium/skills/` | Agent Skills, one flat `.md` each. Source of `skills/` |
| `caveman.md` | Full caveman ruleset, level `full`, for harnesses with no caveman plugin |
| `install.sh` | Installs the sources, then builds the generated files |
| `update-from-machine.sh` | The reverse: pulls this machine's live sources back into the repo |
| `scripts/` | The startup banner, shared by both harnesses |
| `claude/` | Claude Code settings and its statusline script |
| `crush/` | Crush config, with `__HOME__` as the path placeholder |

## Install

```bash
git clone https://github.com/G1anC/J.A.R.V.I.S
cd J.A.R.V.I.S
./install.sh
```

Requires `jq`. The statusline and the startup hook both parse JSON with it.

The installer backs up anything it replaces to `~/.jarvis-backups/<timestamp>/`. It
**replaces `settings.json` and `crush.json` wholesale rather than merging them**, so
merge your own hooks, permissions, MCP servers or providers back from that backup.

## Generated files are not tracked

`AGENTS.md` and `skills/` are build output. `mycelium install agents` concatenates
`~/.mycelium/rules/*.md` into the first and expands `~/.mycelium/skills/*.md` into the
second, and the sync daemon redoes it on its own schedule. Editing either one directly does
not survive. Change `mycelium/rules/` or `mycelium/skills/` instead.

Both are gitignored, so a clone starts with sources only and `install.sh` builds the rest. If
`mycelium` is absent the installer does the same concatenation itself, so the config works
without it, it just never regenerates.

Run `./update-from-machine.sh` to pull your machine's live sources back into the repo before
committing. It filters `settings.json` and rewrites `$HOME` to `__HOME__` on the way in.

## What is not in this repo

Four things stay local, because they are personal rather than configuration:

| Path | Why |
|---|---|
| `AGENTS.local.md` | Author handle, machine names, SSH aliases, infrastructure endpoints, second-brain paths |
| `claude/settings.local.json` | The `autoMode` security profile, which names internal services and sensitive file paths |
| `wiki/` | The agent's own knowledge, including client and business notes |
| `skills/facile-*` | Skills for Facile Studio internal workflows |

`AGENTS.md` carries a pointer to `AGENTS.local.md` rather than the content itself. Claude Code
resolves it as an `@` import; Crush loads it through `global_context_paths`. If the file is
absent the config still works, the agent just has no infrastructure context. Start from
`AGENTS.local.example.md`.

## How each harness is wired

**Claude Code** reads `~/.claude/CLAUDE.md`, which the installer symlinks to
`~/.agents/AGENTS.md`. One file, no copy to drift. Caveman arrives through the plugin's
`SessionStart` hook, so `caveman.md` is unused here.

**Crush** reads `~/.config/crush/crush.json`, which sets `global_context_paths` to
`AGENTS.md` plus `caveman.md`, and `skills_paths` to both `~/.agents/skills` and
`~/.claude/skills`. Crush resolves neither `~` nor `$HOME` in that file, so the installer
substitutes the real path on the way in. The config names a provider but holds no key: it
reads `OPENROUTER_API_KEY` from the environment.

The startup banner is dual-mode. `jarvis-startup.sh --json` emits the `systemMessage` payload
Claude Code's `SessionStart` hook expects; with no flag it prints the banner as plain text.
Crush has no session-start event (v0.82.0 fires only `PreToolUse`, `Stop` and `Notification`),
so `crush/jarvis-crush.zsh` wraps the binary in a shell function that prints the banner and
then execs the real `crush`. Source it from your shell rc. Set `CRUSH_NO_BANNER=1` to mute it,
and it stays quiet when stdout is not a terminal.

**opencode** reads `~/.config/opencode/opencode.jsonc`, pointing `instructions` at the
same two files. Not wired by the installer.

Per-project overrides work as normal: `CLAUDE.md`, `CRUSH.md` or `AGENTS.md`, `.crush.json`.

## Regenerate caveman.md

```sh
node ~/.claude/plugins/cache/caveman/caveman/*/hooks/caveman-activate.js
```

Drop the leading `CAVEMAN MODE ACTIVE` line and keep the rest.

## License

MIT.
