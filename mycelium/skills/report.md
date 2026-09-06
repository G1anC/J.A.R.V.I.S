---
name: report
description: >
  Write a self-contained HTML page and record it with mycelium so it opens on
  the human's machine. Use when an answer is structural rather than linear: a
  comparison across many items, a timeline, a graph, a table wider than a
  terminal. Read this before writing the page.
---

# report — a rendered page that travels between machines

Binary: `mycelium`
Store: `~/.mycelium/reports/`

## When to apply

The gate is in the reports rule and it comes first: three conditions, all of them, or you
answer in the conversation and stop. This skill is the craft once the gate has passed.

## The shape of the work

Two steps, in this order:

1. Write the HTML with your ordinary file tool, into scratch. Iterate there until it is right.
2. `mycelium report add <path>` once. Then tell the human the path it printed.

Never record a draft to iterate on it. `add` replaces by title, so a half-finished page
recorded three times is three syncs of a page nobody asked to see yet.

## Commands

```
mycelium report add <file>            Record it and open it if this machine has a display
  --title <name>                      Override the document's own <title>
  --expires 7d | 12h | never          How long to keep it (default 30d)
  --no-open                           Record without opening a browser
mycelium report list [--json]         Newest first, with machine and time left
mycelium report open <id>             Open it, or print its path on a headless box
mycelium report rm <id>               Delete one
mycelium report sweep                 Delete every expired report
```

## Authoring rules

**Self-contained, without exception.** Inline the CSS in a `<style>`, inline the JS in a
`<script>`, and embed images as `data:` URIs. A page opened from disk gets an opaque origin
and cannot fetch its siblings, so `href="theme.css"` is a stylesheet that silently never
loads. `add` warns about the ones it can see; it cannot see the ones you build in JavaScript.

**No remote fetches.** Offline the page breaks; online it phones out from a page nobody
reviewed. Whatever the data is, put it in the file.

**Light and dark both.** The reader's browser theme is not yours to pick. Define the light
palette on `:root` and override it under `@media (prefers-color-scheme: dark)`. Give `<body>`
an explicit background; a transparent one borrows whatever is behind it.

**Legible on a phone and on paper.** Relative units, `max-width: 100%` on images, and wide
tables inside their own `overflow-x: auto` container so the body never scrolls sideways. These
get opened on a phone and printed more often than you would guess.

**Name the `<title>` well.** It becomes the report's identity and its filename slug. A short
noun phrase specific to this page, not a category label: `Suite drift, August 2026`, not
`Report`. Recording the same title again replaces the page in place, which is how you update
a report rather than accumulate versions of it.

## What to tell the human

The path, and what the page shows. Not a link, because there is not one. If the page was
recorded on a machine with no display, say that it will be on their other machines within a
minute and name the file.

## What this is not

Not the wiki. A fact worth keeping goes in `memory/` as text through `mycelium memory add`,
where search can reach it. A report is the picture of that fact and it expires in thirty days.
Link the finding to the report by name if it helps; never move the finding into the HTML.
