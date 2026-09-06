---
title: Rofi theming limits and capture gotcha
type: tool
sources: [direct observation, rofi 2.0.0-dirty on Hyprland 0.56.0, ~/.config/rofi/wallpaper-select.rasi]
related: [projects/hyprland-wallpaper-setup.md, conventions/desktop-theming-gray.md]
confidence: high
created: 2026-08-02
updated: 2026-08-02
---

### No per-entry background images
**Date**: 2026-08-02
**Source**: direct observation, rofi 2.0.0
`background-image: url(...)` only takes a static path, so a listview entry cannot use its own icon as its background, and rofi has no z-stacking to overlay text on an image. Closest approximation for a thumbnail grid: `element-icon { size: 100%; expand: true; }` with `element { padding: 0px; }` so the image fills the card, and `element-text` as an opaque padded band underneath. Applied in `wallpaper-select.rasi`.

### rofi windows are invisible to grim from an agent shell
**Date**: 2026-08-02
**Source**: direct observation
Launching rofi from a Claude Code Bash call keeps the process alive (exit 124 under `timeout`, so it is waiting for input) but the surface never appears in a `grim` capture of either output, and it logs `DPI auto-detect failed, the output is not known yet`. Waybar restarts from the same shell render fine, so this is specific to rofi's layer surface. Do not burn turns trying to screenshot-verify rofi themes — check the rasi parses (rofi prints theme errors loudly on stderr) and ask gian to press the keybind.
