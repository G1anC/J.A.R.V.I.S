---
title: Typst — facture/devis templates (_PAPERASSE)
type: tool
sources: [/home/gian/_PAPERASSE/typst-templates/, direct observation]
related: [projects/facile-studio.md]
confidence: high
created: 2026-08-18
updated: 2026-08-27
---

### Templates live in `_PAPERASSE/typst-templates/`, one file per document
**Date**: 2026-08-18
**Source**: direct observation
`facile-style.typ` holds tokens + card primitives; `components/*.typ` holds doc-header, parties-grid,
items-table, totals-card, payment-card, signature-grid. Each document (`facture-*.typ`, `devis-*.typ`,
`contrat-*.typ`) declares all its data as `#let` at the top, layout below. New invoice = copy a template,
edit the constants, `typst compile x.typ ../nom.pdf` (PDFs land in `_PAPERASSE/`, not in the repo).
`avoir.typ`, `devis-prestation.typ`, `devis-maintenance.typ` do NOT compile standalone — they contain
`{{mustache}}` placeholders and are meant to be filled by an external generator. Not a regression.

### Page footer clipping: `footer-descent` defaults to 30% of the bottom margin
**Date**: 2026-08-18
**Source**: direct observation (typst 0.15.1)
Legal mentions belong in `#set page(footer: ...)`, not in the content flow — in-flow they get pushed to a
near-empty page 2. But a tall footer silently bleeds off the page edge because the default
`footer-descent` eats 30% of the bottom margin. Set it explicitly (`footer-descent: 0.35cm`) and size the
bottom margin to footer height + descent. Same rule applies to `header-ascent`.

### Fitting a one-page invoice: parametrized card insets
**Date**: 2026-08-18
**Source**: direct observation
`info_card`/`meta_card`/`accent_card` in `facile-style.typ` and `items_table`/`parties_grid` now take an
`inset:` argument (defaults unchanged, so existing docs are untouched). Tightening insets is the biggest
lever for page height — far more than trimming `#v()` spacers. Second biggest: putting totals + payment
cards side by side in a `grid` instead of stacked. When a card is in a half-width column, put the IBAN
label and value on separate lines, else the IBAN wraps mid-number.

### Two gaps in the shared components, and long dates break `meta_card`
**Date**: 2026-08-27
**Source**: direct observation (building `_PAPERASSE/DMS-LAB/devis-*.typ`)
`totals_card` is the one card that does NOT expose `inset:` — when a devis with 5-6 line items spills its
totals onto a near-empty page 2, the insets lever is unavailable there. What actually worked: `items_table`
`row_inset: 0.22cm` (multiplies by row count, biggest single win), page margins `1.7/1.5/2/2`, and a local
`#let logo_height = 46pt` shadowing the import. `signature_grid`'s `field1` param is dead — `make_body`
only renders `field2`/`field3`, so "Nom :" never appears; pass the name positionally instead.
Spelled-out dates ("26 septembre 2026") wrap over three lines inside `doc_header`'s `meta_card` because its
inner table is `columns: (auto, auto)` in a narrow column — use `26/09/2026` in the meta rows.
