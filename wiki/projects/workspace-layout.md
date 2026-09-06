---
title: Workspace layout — ~/_WORK
type: project
sources: ["direct observation 2026-08-10", "user decision"]
related: ["projects/facile-studio.md", "conventions/facile-component-style.md"]
confidence: high
created: 2026-08-10
updated: 2026-08-10
---

# Workspace layout

### `_DEV` and `_FACILE` merged into `_WORK`
**Date**: 2026-08-10
**Source**: direct observation (restructure performed on request)

All project directories now live under `~/_WORK`. The old `~/_DEV` and `~/_FACILE`
roots are gone — any absolute path referencing them is stale.

```
~/_WORK/
|-- facile/          # Facile Studio client sites + internal tools
|   |-- EvelyneCrea-v1/   (FacileStudio/Evelynecrea.git — Next, superseded)
|   |-- EvelyneCrea-v2/   (FacileStudio/evelyneCreaV2.git — turborepo, current)
|   |-- Hottake/ Laura/ LPB/ MarionMasson/ Vitrine/
|   `-- OUTILS/           # internal tools
|       |-- muse/ muse-preview/ Opus/ Sablier/ Scribe/
|       `-- Boilerplate/ front_base/ dither-test/
|-- perso/           # personal projects
|   |-- Waves/ Zori/ dither-gpu/
|   `-- ressources/dithering-shader/
`-- _archive/        # superseded material, safe to delete
```

`muse-preview/package.json` depends on `"@facile/lib": "file:../muse"` — `muse` and
`muse-preview` must stay siblings inside `OUTILS/`, and `muse` must stay lowercase.

`~/_DEV/HandVision/` was left behind: the whole tree is root-owned and empty
(`BackEnd/uploads` only), so `mv` fails without `sudo`. Remove with
`sudo rm -rf ~/_DEV` when convenient.

`_FACILE/newPortfolio` and `_FACILE/tmp` were untracked older snapshots of the same
codebase as `Vitrine` and were deleted; source-only tarballs sit in `_WORK/_archive/`.
