---
title: Flatpak sideloaded bundles never update
type: tool
sources: ["direct observation", "https://github.com/deadlock-mod-manager/deadlock-mod-manager/releases"]
related: ["bugs/flatpak-nvidia-gl-mismatch.md"]
confidence: high
created: 2026-08-10
updated: 2026-08-10
---

# Flatpak sideloaded bundles

### `flatpak update` is a no-op for `.flatpak` bundles
**Date**: 2026-08-10
**Source**: direct observation (dev.stormix.deadlock-mod-manager 0.15.0 -> 1.1.0)
Apps installed from a downloaded `.flatpak` bundle get a synthetic origin (`<app>-origin`) with no remote URL, so `flatpak update` reports "Nothing to update" forever, no matter how old they are. Updating means downloading the new bundle and re-running `flatpak install --user --bundle <file>`, which upgrades in place and keeps app data in `~/.var/app/<id>`.

### Bundle `Version:` field can lie
**Date**: 2026-08-10
**Source**: direct observation
`flatpak info` reads `Version:` from the app's metainfo XML, which upstream often forgets to bump. Verify with the ostree `Commit:`/`Date:` line instead — the v1.1.0 deadlock-mod-manager bundle still declares `Version: 1.0.0` but carries the 2026-08-01 build.

### Duplicate system + user installs
**Date**: 2026-08-10
**Source**: direct observation
Same app can sit in both the system and user installation; the user one wins at launch. Sideloading only ever touches the scope named by `--user`/`--system`, so the other copy silently rots. Check with `flatpak list --columns=application,installation,version`.
