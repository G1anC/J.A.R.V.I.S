---
title: Facile component code style — comments + spacing
type: convention
sources: [/home/gian/_WORK/facile/LPB/apps/client/src/routes/(site)/(home)/ManifestoSection.svelte, /home/gian/_WORK/facile/Vitrine/app/[locale]/homeSections/manifesto.tsx, direct request from gian]
related: [scroll-reveal-anchor-system.md]
confidence: high
created: 2026-06-18
updated: 2026-06-18
---

### How gian wants Facile components structured

**Date**: 2026-06-18
**Source**: direct request from gian (applies to all Facile component work)

This OVERRIDES the global "never add inline comments" rule, but only for the **logic / dev part** of Facile components (script block, hooks, handlers, derived values). Apply by default to Facile `.svelte` / `.tsx` components.

Rules:

1. **Comment the dev part, not the markup.** Group the logic with short lowercase comments: `// config`, `// dom refs`, `// sentinel refs`, `// state`, then a one-line descriptive comment before each effect / handler describing intent (e.g. `// anchors: derive every flag from sentinel positions`). NO comments inside the HTML/JSX/template.

2. **Blank-line separation.** Put a blank line between grouped declarations, and a **double blank line** between major logic blocks (e.g. between separate `useEffect` / `$effect` blocks) — matches the LPB Svelte files.

3. **Keep `\n` between important markup parts.** In the JSX/HTML, separate the meaningful structural blocks (each layer/region) with a blank line so the markup stays scannable — but do not annotate them with comments.

4. Indentation 4 spaces (gian's global rule).

Reference file that embodies this: `_WORK/facile/Vitrine/app/[locale]/homeSections/manifesto.tsx`.
