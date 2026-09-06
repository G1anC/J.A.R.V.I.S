---
title: GSAP FLIP jumps instead of animating (React StrictMode double effect)
type: bug
sources: [/home/gian/_WORK/facile/Vitrine/app/[locale]/projects/projectDetail.tsx, "user report 2026-08-08"]
related: [react-hooks-lint-vitrine.md]
confidence: medium
created: 2026-08-08
updated: 2026-08-08
---

### A hand-rolled FLIP must measure with transforms cleared

**Date**: 2026-08-08
**Source**: user report ("l'image jump directement à la bonne taille") + code reasoning, Next 16 dev

Next 16 leaves `reactStrictMode` on by default, so a `useLayoutEffect` runs → cleanup → runs again with **no paint
in between**. If the cleanup only does `tl.kill()`, the element keeps the transform the first pass applied. The
second pass then calls `getBoundingClientRect()` on that still-transformed element, so `first ≈ last`, the computed
scale is ~1 and the delta ~0 → the element snaps to its final size with no animation at all.

Fix: clear before measuring, in the effect itself.

```ts
gsap.set(el, { clearProps: "all" });          // measure clean
const last = el.getBoundingClientRect();
gsap.set(el, { x: dx, y: dy, scale: s, transformOrigin: "top left" });
tl.to(el, { x: 0, y: 0, scale: 1, ... }, 0);
```

Two related habits:
- Prefer `gsap.set(from)` + `tl.to(...)` over `tl.fromTo(...)` for entry choreography — the from-state is applied
  synchronously in the layout effect, with no `immediateRender` timing to reason about.
- For the reverse flip, **compose** with what the element already carries
  (`x + (first.left - last.left)`, `scale * (first.width / last.width)`, origin `top left`), so closing mid-open
  still lands exactly on the source element.

Nested horizontal smooth scroll in the same file: `new Lenis({ wrapper, content, orientation: "horizontal",
gestureOrientation: "both", autoRaf: false })` driven by `gsap.ticker.add(t => lenis.raf(t * 1000))` — a vertical
wheel then glides the track sideways. Beats hand-tweening `scrollLeft`.
