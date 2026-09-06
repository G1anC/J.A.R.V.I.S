---
title: Flatpak Steam won't open on Hyprland/HyDE — DISPLAY missing from flatpak portal activation env
type: bug
sources: [direct observation, https://github.com/ValveSoftware/steam-for-linux/issues/10554]
related: [bugs/flatpak-steam-xwayland-empty-cookie.md]
confidence: high
created: 2026-07-10
updated: 2026-07-10
---

### Flatpak Steam shows "requires a correctly-configured desktop session / DISPLAY in D-Bus activation env" dialog + no window on Hyprland (HyDE)
**Date**: 2026-07-10
**Source**: direct observation (host Icarus, Hyprland via HyDE dotfiles, flatpak com.valvesoftware.Steam), Valve issue #10554

**Symptom**: On Hyprland, `flatpak run com.valvesoftware.Steam` pops a zenity dialog every launch: *"The unofficial Steam Flatpak app requires a correctly-configured desktop session, which must provide the DISPLAY environment variable to the D-Bus session bus activation environment ... dbus-update-activation-environment DISPLAY ... see steam-for-linux/issues/10554"*. Webhelper crash-loops with `ozone_platform_x11.cc: Missing X server or $DISPLAY`. Native (non-flatpak) X apps work fine. Same flatpak works on KDE.

**Root cause**: flatpak Steam launches its webhelper on the host via the Flatpak portal (`steam-runtime-launch-client --bus-name=org.freedesktop.portal.Flatpak`). The spawned process inherits env from `flatpak-portal` / `flatpak-session-helper`, which are systemd --user / dbus-broker activated. On HyDE those services start at login **without `DISPLAY`**, because HyDE's env-share omits it:
`~/.local/share/hyde/hyde.conf` → `SYSTEMD_SHARE_PICKER=systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP` (no DISPLAY). Also the login-time `dbus-update-activation-environment --systemd --all` runs before Xwayland has assigned `DISPLAY=:1`, so it captures nothing.
Diagnosis clincher: `for p in $(pgrep -f 'flatpak-portal|flatpak-session-helper'); do tr '\0' '\n' </proc/$p/environ | grep ^DISPLAY; done` → `DISPLAY=<UNSET>`.

**Fix (this session)**:
```
dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
systemctl --user import-environment DISPLAY
systemctl --user restart flatpak-portal.service flatpak-session-helper.service
```
Then relaunch Steam. Portal/helper now carry `DISPLAY=:1`; webhelper connects, "Sign in to Steam" window appears (12 steamwebhelper procs).

**Fix (permanent, unified 2026-07-13)**: single session-agnostic script `~/.local/bin/steam-session-fix.sh` now serves BOTH sessions — it waits for Xwayland, pushes DISPLAY to the activation env + restarts the two portal services (Hyprland need), AND runs `xhost +SI:localuser:$USER` (KDE empty-cookie need). Both halves are harmless on the session that doesn't need them. Wired via `exec-once = ~/.local/bin/steam-session-fix.sh` in `~/.config/hypr/userprefs.conf` and `Exec=/home/gian/.local/bin/steam-session-fix.sh` in `~/.config/autostart/xhost-localuser.desktop` (OnlyShowIn=KDE). Old `~/.config/hypr/scripts/fix-flatpak-display.sh` orphaned (kept, harmless). Verified: 12 webhelper procs on KDE, window atoms cached, no auth errors.

**Red herrings that wasted time**: X auth cookies (Hyprland's Xwayland runs `-rootless` with NO `-auth` → accepts no-auth local connections; verified a raw X11 handshake to `:1` returns SUCCESS with empty XAUTHORITY). Creating `~/.Xauthority` did nothing and briefly broke things. This is NOT the same as the KDE empty-cookie bug — see [[flatpak-steam-xwayland-empty-cookie]].

**Gotcha for the agent**: `pkill -9 -f steam-runtime` / broad steam kills will also kill running **Proton game containers** (e.g. an in-progress RDR2 VC++ redist install shares the steam-runtime/pressure-vessel process tree). Kill only `steamwebhelper` + `ubuntu12_32/steam` for the client. Repeated `kill -9` during pressure-vessel bootstrap corrupts its runtime (`/run/user/1000/pressure-vessel`, `steamrt64/pv-runtime/.../var/tmp-*`) and makes webhelper hang before CEF; clear those dirs or re-login to recover.
