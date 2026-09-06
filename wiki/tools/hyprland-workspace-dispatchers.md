---
title: Hyprland workspace dispatcher relative args (e vs r vs plain)
type: tool
sources: [direct observation via hyprctl dispatch, Hyprland 0.56.0]
related: [conventions/desktop-theming-gray.md]
confidence: high
created: 2026-08-02
updated: 2026-08-02
---

### e±1 wraps among existing workspaces, r±1 creates new ones
**Date**: 2026-08-02
**Source**: direct observation, Hyprland 0.56.0, workspaces [1,3,4,6] active on 3
Measured with `hyprctl dispatch workspace <arg>`:

| arg | from 3 | from 4 | from 6 (highest) |
|---|---|---|---|
| `+1` | 4 | 5 | 7 (new) |
| `e+1` | 4 | 6 | 1 (wraps) |
| `r+1` | 5 | 5 | 7 (new) |
| `m+1` | 3 | — | — |

`e±1` skips gaps and wraps around the set of open workspaces — it can never reach an unused ID, which reads as erratic ("swaps back and forth, never gets a fresh workspace"). `r±1` is plain numeric-relative and will create the next workspace. `r-1` at workspace 1 clamps to 1, no wrap. HyDE binds `r±1`; gian wants that behavior.

Applied in `~/.config/hypr/configs/binds.conf`: `SUPER SHIFT Left/Right` and `SUPER period/comma` moved from `e±1` to `r±1`. Mouse scroll binds deliberately kept on `e±1` — `r±1` on a scroll wheel spawns workspaces without limit.

`hyprctl binds -j` emits invalid JSON in 0.56.0 (unquoted values around the `arg` field); parse the plain-text `hyprctl binds` output instead.
