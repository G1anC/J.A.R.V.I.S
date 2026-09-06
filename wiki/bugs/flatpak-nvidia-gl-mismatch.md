---
title: Flatpak GPU apps hang after NVIDIA driver bump
type: bug
sources: [direct observation]
related: []
confidence: high
created: 2026-07-07
updated: 2026-07-07
---

### Flatpak GPU apps hang silently when NVIDIA GL runtime != host driver
**Date**: 2026-07-07
**Source**: direct observation

Symptom: Flatpak apps needing GPU (Steam `com.valvesoftware.Steam`, Deadlock mod
manager `dev.stormix.deadlock-mod-manager`, any Electron/Tauri) launch, print
early stdout (`Overriding TZ...`), then hang with no window and no error.

Cause: host kernel NVIDIA driver was bumped (`cat /sys/module/nvidia/version`
showed `610.43.02`) but Flatpak still had `org.freedesktop.Platform.GL.nvidia-595-71-05`.
Flatpak needs `org.freedesktop.Platform.GL.nvidia-<host-version>` (+ GL32 for
32-bit apps like Steam) exactly matching host driver, else GL never inits.

Fix:
1. `flatpak kill com.valvesoftware.Steam` then `pkill -9 -f valvesoftware.Steam`
   (a hung instance leaves zombie `<defunct>` children under a `bwrap` tree; new
   launches attach to it and do nothing).
2. `flatpak update -y` — auto-uninstalls old nvidia GL ext, installs matching one.
3. Verify: `flatpak list | grep GL.nvidia` version == `cat /sys/module/nvidia/version`.

Rule: after ANY NVIDIA driver update, run `flatpak update` before launching
Flatpak GPU apps.
