---
title: swaync-client hangs forever, cc DBus name unowned
type: bug
sources: [direct observation, busctl --user list, ~/.config/hypr/scripts/apply_wal_theme.sh]
related: [conventions/desktop-theming-gray.md, projects/hyprland-wallpaper-setup.md]
confidence: medium
created: 2026-08-02
updated: 2026-08-02
---

### swaync-client -rs / -R never return on this machine
**Date**: 2026-08-02
**Source**: direct observation, swaync 0.12.6
`swaync-client -rs` prints `Could not connect to CC service. Will wait for connection...` and blocks indefinitely. `busctl --user list` shows `org.erikreider.swaync.cc` as `(activatable)` but unowned, while a `swaync` process is running. Consequence: every past `apply_wal_theme.sh` run (which ends in `swaync-client -rs`) left a zombie `swaync-client` — ~15 were parked in the session. Asking for the name also DBus-activates a second `/usr/bin/swaync` under the dbus daemon, so duplicate swaync processes accumulate.

Root cause not confirmed. Do not try to fix by killing/restarting swaync mid-session — gian rejected that. Style edits under `~/.config/swaync/style/` land on the next natural swaync restart instead. Treat a hanging `swaync-client` as expected here, always wrap it in `timeout`.
