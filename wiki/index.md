# Wiki Index

## Projects
- [Facile Studio](projects/facile-studio.md) — web creation studio, team, tools, vision
- [Workspace layout](projects/workspace-layout.md) — all projects live under `~/_WORK`; `_DEV`/`_FACILE` are gone
- [Hyprland wallpaper setup](projects/hyprland-wallpaper-setup.md) — custom swww scripts + `~/wallpaper/wallpaper.png` symlink, not HyDE's theme system

## Conventions
- [Scroll-reveal anchor system](conventions/scroll-reveal-anchor-system.md) — default way to build scroll-reveal effects (LPB sentinel/flag pattern)
- [Facile component code style](conventions/facile-component-style.md) — comments on the dev part only, blank-line separation, no markup comments
- [react-hooks v6 lint in Vitrine](conventions/react-hooks-lint-vitrine.md) — refs can't be passed to helpers from render scope, `style.setProperty` instead of style assignment
- [Desktop gray-tint knobs](conventions/desktop-theming-gray.md) — single `mix()` color per app for waybar/swaync, literal hex for rofi, theme-scoped overrides for VS Code

## Tools
- [Rofi theming limits](tools/rofi.md) — no per-entry background images; rofi surfaces don't show up in agent-side `grim` captures
- [Hyprland workspace dispatchers](tools/hyprland-workspace-dispatchers.md) — `e±1` wraps among open workspaces, `r±1` creates new; measured table
- [Flatpak sideloaded bundles](tools/flatpak-sideloaded-bundles.md) — `flatpak update` never updates `.flatpak` sideloads; re-install the bundle, and don't trust `Version:`
- [Typst facture/devis templates](tools/typst.md) — `_PAPERASSE/typst-templates` layout; `footer-descent` clips tall page footers; insets are the page-height lever

## Bugs
- [GSAP FLIP jumps, no animation](bugs/gsap-flip-strictmode-measure.md) — StrictMode's double layout effect leaves a transform; clear props before measuring
- [Flatpak NVIDIA GL mismatch](bugs/flatpak-nvidia-gl-mismatch.md) — flatpak GPU apps hang after host NVIDIA driver bump; run `flatpak update`
- [Flatpak Steam no window on KDE Wayland](bugs/flatpak-steam-xwayland-empty-cookie.md) — empty X cookie in pressure-vessel; fix `xhost +SI:localuser:$USER`
- [swaync-client hangs on DBus](bugs/swaync-client-hangs-dbus.md) — cc name unowned, `-rs`/`-R` block forever, zombie clients pile up; always wrap in `timeout`
- [Flatpak Steam won't open on Hyprland/HyDE](bugs/flatpak-steam-hyprland-display-activation-env.md) — DISPLAY missing from flatpak-portal activation env; push DISPLAY + restart flatpak-portal/session-helper

## Syntheses
_(none yet)_
