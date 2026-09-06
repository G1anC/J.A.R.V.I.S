---
title: Scroll-reveal effects — use the LPB anchor system
type: convention
sources: [/home/gian/_WORK/facile/LPB/apps/client/src/routes/(site)/(home)/ManifestoSection.svelte, /home/gian/_WORK/facile/LPB/apps/client/src/routes/(site)/(home)/components/manifesto/Text.svelte, /home/gian/_WORK/facile/LPB/apps/client/src/routes/(site)/(home)/components/manifesto/Images.svelte, direct observation]
related: []
confidence: high
created: 2026-06-18
updated: 2026-08-17
---

### Default pattern for scroll-driven reveal effects (gian's preference)

**Date**: 2026-06-18
**Source**: Les P'tits Bonheurs (LPB) Manifesto, direct request from gian

When building scroll-reveal / scroll-choreography effects for gian (Facile projects), DO NOT scrub a GSAP timeline against scroll value. Use the **LPB anchor system** — gian finds it by far the simplest to read and reason about. He asked this be the default going forward.

The anchor system has three parts:

1. **Tall section + sticky stage.** Section is `min-h-[Nvh]` (e.g. 250vh) to create scroll room. The visual lives in a `sticky top-0 h-screen overflow-hidden` child so it pins while you scroll through the section.

2. **Sentinels + boolean flags (the "anchor").** Invisible `absolute top-[X%] w-full h-px` divs placed at chosen depths. A single `scroll` listener reads `sentinel.getBoundingClientRect().top < 0` and flips plain boolean state flags. Flags drive *discrete* reveals (show text, show CTA, swap text index) — not continuous interpolation. In LPB the listener is on `sectionEl.parentElement`; on a normal window-scroll page use `window`.

3. **Reveal via overflow-hidden + translate.** Each line/element sits in an `overflow-hidden` wrapper; the inner translates `translateY(110%) -> translateY(0)` when its flag turns true. Stagger lines with an increasing `transition-delay` (e.g. `i * 0.1s`). CTA = same trick, inner `translateY(100%) -> 0`.

Other rules learned with it:
- **Reveal animations that should "just play" (not follow scroll):** trigger once with an `IntersectionObserver` (set a `revealed` flag), then animate with CSS `transition` + per-element `transition-delay` for the stagger. No timeline scrubbing.
- **"One model shown only inside the white panels" without duplicating it:** keep ONE model element (full-screen, white bg + dither child) and reveal it with **retracting cover panels** painted in the page background colour (`bg-background`) that shrink `height: 100% -> 0%` per column with staggered delay. The covers are cheap plain divs; the model stays a single element. This avoids both CSS-mask `%`-position pitfalls and N duplicated model copies.
- **Model parallax drift** is a separate `pointermove` -> `gsap.to(model, {x,y})`, fully decoupled from the reveal.
- **Anchor in stable units.** When clipping/offsetting, anchor to a fixed edge in `vh`/`vw` or via `overflow-hidden` windows — never rely on `mask-position` percentages (they resolve against `container - image`, not "offset from top", and cause gaps).

Reference implementations: LPB `ManifestoSection.svelte` (Svelte 5), and Facile Vitrine `app/[locale]/homeSections/manifesto.tsx` (React/Next — same pattern ported).


### Vitrine: `TextReveal` is the only crop, `BlockReveal` lives in muse

**Date**: 2026-08-17
**Source**: /home/gian/_WORK/facile/Vitrine/components/facile/textReveal.tsx, direct request from gian

The panel-wipe reveal (`BlockReveal` — a solid slab wiping across the copy) was tried across the
whole Vitrine and **rejected: it does not work on the light theme**. It now lives in muse as
`src/lib/components/motion/BlockReveal.svelte` (Svelte, `panel="accent" | "page"`) and must not
come back into Vitrine.

Every crop-and-slide reveal in Vitrine goes through **one** component,
`components/facile/textReveal.tsx`, in one of two modes — never hand-written markup:
- `<TextReveal open={show} leaving={leaving} delay={…}>` — the parent knows when; it tweens itself.
- `<TextReveal>` — renders `[data-reveal]` and no motion; the nearest ancestor observer (shelf
  index, story index, orbit) pre-hides it with `hideRevealY` and plays `slideY`.
`className` styles the sliding element, `cropClassName` the `overflow-hidden` box (margins,
width). The story's blocks import it as `Line`; `SplitLines` builds the same markup per visual
line for wrapped copy.
