---
title: Hyprland wallpaper setup (custom scripts over HyDE)
type: project
sources: [~/.config/hypr/scripts/, ~/.config/hypr/configs/binds.conf, ~/.config/hyde/themes/, direct observation]
related: [bugs/flatpak-steam-hyprland-display-activation-env.md]
confidence: high
created: 2026-08-02
updated: 2026-08-02
---

### Wallpaper pipeline is custom, not HyDE's
**Date**: 2026-08-02
**Source**: direct observation, `~/.config/hypr/scripts/`
HyDE is installed (`~/.config/hyde/`) but wallpapers are driven by hand-written scripts, not `hyde` CLI or `swwwallpaper.sh`. Flow: script `ln -sf <image> ~/wallpaper/wallpaper.png`, then `set_wallpaper.sh` runs `swww img` (grow transition from `hyprctl cursorpos`), then `apply_wal_theme.sh` regenerates pywal colors. `hyprlock.conf` reads the same symlink. Do not "fix" this by invoking HyDE theme commands — they manage a separate theme state.

### Picker constraints in wallpaper_select.sh
**Date**: 2026-08-02
**Source**: `~/.config/hypr/scripts/wallpaper_select.sh:8,14`
Rofi label and match key are `basename | cut -d. -f1`, so any filename with a dot before the extension truncates and can collide with another entry. New wallpapers must have exactly one dot. The picker globs all of `~/wallpaper/*` including the `wallpaper.png` symlink itself. Keybinds: `SUPER SHIFT W` picker, `SUPER ALT ←/→` random.

### Symlink can self-loop and kill the wallpaper
**Date**: 2026-08-02
**Source**: direct observation, `~/.config/hypr/scripts/random_wallpaper.sh:56`, `wallpaper_select.sh:8`
Both pickers glob `~/wallpaper/*`, which includes `wallpaper.png` itself. If that entry is picked, `ln -sf` makes `wallpaper.png -> ~/wallpaper//wallpaper.png` — a self-loop, so `set_wallpaper.sh` bails with "No wallpaper found" and the last `swww` image stays on screen forever. Diagnose with `test -e ~/wallpaper/wallpaper.png`; fix with `rm` then relink to a real file. Never re-run `random_wallpaper.sh` to repair it — with a broken symlink `[ ! -f "$CURRENT_IMAGE" ]` is true and it can re-pick the same entry.

### swww client needs the session env untouched
**Date**: 2026-08-02
**Source**: direct observation
Daemon runs under namespace `awww-daemon` (layer name in `hyprctl layers`, socket `/run/user/1000-awww-daemon.sock`). Running `swww` from an agent shell works as-is; exporting `WAYLAND_DISPLAY`/`XDG_RUNTIME_DIR` by hand breaks socket resolution. Also note `pgrep -a swww` shows nothing while the daemon is live — use `swww query` or `hyprctl layers` instead.

### HyDE theme wallpapers imported
**Date**: 2026-08-02
**Source**: direct observation
114 images from `~/.config/hyde/themes/*/wallpapers/` copied into `~/wallpaper/` as `<theme-slug>-<name-slug>.<ext>` (spaces and unicode slugified for the picker). `~/Pictures/wallpapers/` holds an older duplicate set of the 8 theme-name wallpapers plus `current.png` — stale, not read by any script.
