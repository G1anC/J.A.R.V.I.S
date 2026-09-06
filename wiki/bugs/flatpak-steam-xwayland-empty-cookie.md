---
title: Flatpak Steam no window on KDE Wayland — empty X cookie in pressure-vessel
type: bug
sources: [direct observation]
related: [bugs/flatpak-nvidia-gl-mismatch.md]
confidence: high
created: 2026-07-10
updated: 2026-07-10
---

### Flatpak Steam opens no window on KDE Plasma Wayland (works on Hyprland)
**Date**: 2026-07-10
**Source**: direct observation (host Icarus, KDE Plasma Wayland, flatpak com.valvesoftware.Steam)

**Symptom**: `steam` (aliased to `flatpak run com.valvesoftware.Steam`) starts, client processes run, but no window ever appears. `steamwebhelper` (CEF, the renderer) crash-loops every ~10s. Same flatpak install works fine on Hyprland.

**Logs** (`~/.var/app/com.valvesoftware.Steam/.local/share/Steam/logs/`):
- `cef_log.txt` / `webhelper-linux.txt`:
  - `Authorization required, but no authorization protocol specified`
  - `ERROR:ozone_platform_x11.cc(246)] Missing X server or $DISPLAY`
  - `Assertion Failed: SDL_Init failed: No available video device`

**Root cause**: X11 auth cookie not reaching Steam's nested **pressure-vessel** container. On KDE/SDDM the cookie lives at a non-standard path (`/run/user/1000/xauth_PIKLYn`). flatpak copies it to `/run/flatpak/Xauthority` (96 bytes, valid at the flatpak layer), but pressure-vessel rebuilds `/run` as fresh tmpfs and the bound cookie is **0 bytes inside the container**. Webhelper sends empty auth → XWayland rejects → no display. Confirmed by probing inside pv:
```
EP=~/.local/share/Steam/steamrt64/pv-runtime/steam-runtime-steamrt/_v2-entry-point
"$EP" --verb=run -- sh -c 'ls -l $XAUTHORITY'   # -> /run/flatpak/Xauthority = 0 bytes
```

**Fix that works**: bypass the cookie requirement entirely via xhost.
```
sudo pacman -S --needed xorg-xhost
xhost +SI:localuser:$USER
```
Then relaunch Steam. Makes XWayland accept local-user connections with no cookie, so the empty-cookie-in-pv problem stops mattering. Verify: `cef_log.txt` shows 0 `Missing X server` errors and `pgrep -fc steamwebhelper` jumps to ~12.

**Persistence**: xhost ACL resets on logout. Made permanent with KDE autostart (scoped so it never touches Hyprland): `~/.config/autostart/xhost-localuser.desktop`, `OnlyShowIn=KDE;`. As of 2026-07-13 that autostart calls the unified `~/.local/bin/steam-session-fix.sh` (xhost + DISPLAY-push), the same script Hyprland runs via exec-once — see [[flatpak-steam-hyprland-display-activation-env]].

**Did NOT work**: `PRESSURE_VESSEL_FILESYSTEMS_RO=/run/flatpak/Xauthority`; `--nosocket=x11` + manual `--filesystem=/tmp/.X11-unix` + `--env=XAUTHORITY=$HOME/.Xauthority` (populated the inner cookie but broke the socket/DISPLAY path → still "Missing X server"). Reinstalling Steam is useless — install is fine, it's a session/X-auth issue.
