---
title: Desktop gray-tint knobs (waybar, swaync, rofi, VS Code)
type: convention
sources: [~/.config/waybar/style.css, ~/.config/swaync/style/, ~/.config/rofi/*.rasi, ~/.config/Code - OSS/User/settings.json, direct observation]
related: [projects/hyprland-wallpaper-setup.md]
confidence: high
created: 2026-08-02
updated: 2026-08-02
---

### Single-knob gray tint per app
**Date**: 2026-08-02
**Source**: direct observation
gian wants surfaces desaturated toward neutral gray while keeping wallpaper/pywal tint. Pattern used: one `@define-color` mixing the app's base background toward a gray, then every background rule references it.
- waybar `style.css:4` — `@define-color bg-gray mix(@background, #9a9a9a, 0.5);`, all 6 background rules use `alpha(@bg-gray, …)`
- swaync `style/notifications.css` + `style/control-center.css` lines 2 and 8 — same mix applied to `@bg` and `@background-alt`
Raise the mix fraction for grayer, change the gray hex for lighter/darker. Only touch background surfaces — leave `@selected`/`@hover`/accent colors alone or the theme reads dead.

### Rofi rasi has no color-mix function
**Date**: 2026-08-02
**Source**: `man rofi-theme` (rofi 2.0.0), direct observation
Unlike GTK CSS, rasi has no `mix()`/`shade()`/`lighten()`. Rofi backgrounds must be precomputed literal hex. Current values (gray mix 0.5 toward `#9a9a9a`, alpha preserved): `config.rasi`/`clipboard.rasi` use `#52525333` and `rgba(77,77,77,0.2)`; `wallpaper-select.rasi` uses `#4d4d4d1a` and `#4d4d4d33`. Recompute by hand when the gray level changes.

### VS Code backgrounds without losing Tokyo Night
**Date**: 2026-08-02
**Source**: `~/.config/Code - OSS/User/settings.json`, direct observation
Editor is Code - OSS with `window.autoDetectColorScheme`, dark = Tokyo Night Storm, light entry = Tokyo Night. Backgrounds overridden via theme-scoped `workbench.colorCustomizations` blocks (`"[Tokyo Night Storm]"`, `"[Tokyo Night]"`) set to kitty's base `#0a0a0d`, active tab/input `#15151a`. Only background keys are overridden so syntax colors stay Tokyo Night. Same pattern as the pre-existing `[Catppuccin Latte]` block — follow it for any new theme.
A mid-gray (`#33343b`) was tried first to match the waybar/rofi tint and gian rejected it hard: bars are translucent over the wallpaper, VS Code is opaque, so equal hex does not read as equal surface. Match kitty's flat color instead.

### APC extension is installed but NOT enabled
**Date**: 2026-08-02
**Source**: direct observation, `grep -c apc /usr/lib/code/out/vs/workbench/workbench.desktop.main.js` → 0
`drcika.apc-extension-0.4.1` is present and `apc.font.family` / `apc.monospace.font.family` are set, but the workbench bundle has no APC patch markers, so those settings are currently inert. `/usr/lib/code` is writable by gian (owner gian, group root), so the in-editor "Enable APC extension" command can patch it without sudo. APC is also the only route to real VS Code window transparency (Electron `transparent: true` + 8-digit alpha background colors) — VS Code has no native support. Do not patch the install files directly; that command is the user's call.
