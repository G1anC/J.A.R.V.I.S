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
| `AGENTS.md` | Base policy: persona, core rules, git and code style, wiki protocol |
| `caveman.md` | Full caveman ruleset, level `full`, for harnesses with no caveman plugin |
| `skills/` | Agent Skills, one `SKILL.md` folder each |
| `wiki/` | Durable knowledge the agent maintains itself, gitignored |
| `AGENTS.local.md` | Machine-local profile and infrastructure, gitignored |
| `claude/` | Claude Code settings and hook scripts |
| `crush/` | Crush config, with `__HOME__` as the path placeholder |
| `install.sh` | Wires all of the above into a machine |

## Install

```bash
git clone https://github.com/G1anC/j.a.r.v.i.s
cd j.a.r.v.i.s
./install.sh
```

Requires `jq`. The statusline and the startup hook both parse JSON with it.

The installer backs up anything it replaces to `~/.jarvis-backups/<timestamp>/`. It
**replaces `settings.json` and `crush.json` wholesale rather than merging them**, so
merge your own hooks, permissions, MCP servers or providers back from that backup.

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
