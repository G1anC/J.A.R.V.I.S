---
title: react-hooks v6 lint rules in Vitrine (Next 16)
type: convention
sources: [/home/gian/_WORK/facile/Vitrine/app/[locale]/projects/projectDetail.tsx, "direct observation 2026-08-08"]
related: [facile-component-style.md]
confidence: high
created: 2026-08-08
updated: 2026-08-08
---

### eslint-config-next 16 ships the compiler-era react-hooks rules — they break common GSAP patterns

**Date**: 2026-08-08
**Source**: direct observation (eslint run on `_WORK/facile/Vitrine`, baseline repo is 0 problems)

`bunx eslint <dir>` in Vitrine enforces `react-hooks/refs` and `react-hooks/immutability` as **errors**.
Two patterns that look fine and are used all over GSAP code get rejected:

1. **Passing `someRef.current` (an array of elements) to a helper** — e.g. `hideRevealY(chromeRefs.current)`,
   `run(chromeRefs.current, slideY(...))` — errors with *"Cannot access refs during render"*, reported at the
   ref-setter line, once per JSX call site. It fires when the ref also feeds a function created in render scope
   (a `useCallback` handler), even though the read happens later.
   *Fixes*: copy the array (`[...ref.current]`) when the call is inside an effect, or drop the ref array entirely
   and query the DOM: tag the nodes `data-chrome` and do
   `Array.from(rootRef.current?.querySelectorAll<HTMLElement>("[data-chrome]") ?? [])`.
   The query approach also matches the repo's existing `[data-reveal]` pattern. Element refs used only via
   methods (`ref.current.filter(...)`, `gsap.set(ref.current, …)` in a handler) are fine.

2. **Assigning to `document.documentElement.style.*`** (scroll lock) errors with *"This value cannot be modified"*.
   Use the method form instead: `html.style.setProperty("overflow", "hidden")` /
   `html.style.setProperty("padding-right", prev)`.

`react-hooks/exhaustive-deps` is only a warning but the repo baseline is clean, so keep it clean: mirror
`hooks/use-scroll.ts` — hold props/callbacks in a ref synced by a bare `useEffect(() => { ref.current = prop; })`,
then `useCallback(..., [])` over those refs and list the callback in the dependent effect's deps.

`bun run build` does **not** run eslint, so lint explicitly before claiming a change is clean.
