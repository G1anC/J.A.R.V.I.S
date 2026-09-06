---
title: Facile Studio
type: project
sources: ["direct observation", "user statements 2026-05-17"]
related: []
confidence: high
created: 2026-05-17
updated: 2026-05-17
---


# Facile Studio

Web creation studio founded in Berlin by Noah and saravenpi. Goal: build a studio that creates for the web — agency work + open source tooling.

## Team

| Handle | Real name | Role | Location |
|---|---|---|---|
| `gian` / Noah | Noah Steiniger | Web designer, co-founder | Berlin → Strasbourg (returning ~late 2026) |
| `saravenpi` | — | Lead developer, tooling architect | Berlin |
| `MezzMTV` / Mazouz | — | Developer (clean/reusable/sexy code), recently joined | Morocco |
| Camille | — | Graphic designer, visual identity | — |

Noah and Camille are partners (3 years). Noah and Mazouz met first year of master at EPITECH Strasbourg.

## Products / Tools

### Internal tooling ecosystem

```
Opus ──────────────────────────┐
                               ↓
Sablier (time tracking) ───────┤
                               ↓
Nook (activity monitor) ──→ Matrix server (notifications)
                               ↓
                          Perception (Claude secretary)
```

- **Opus** — task tracker (similar to Linear/Vicunja). Tracks every task in a project.
- **Sablier** — time tracking. Will link with Opus to calculate time spent per task.
- **Nook** — monitors activity across all apps, sends notifications to the team's Matrix server.
- **Perception** — aggregator app with an embedded Claude instance. Receives all data from Nook, acts as company secretary — gathers all company info in one place.
- **Muse** — shared component library, Facile visual language, planned open source. Every Facile tool uses it. Developers who adopt it should credit Facile Studio.
- **Boilerplate** — project starter, maintained by saravenpi.
- More tools incoming as studio grows.

## Stack

Svelte 5 + SvelteKit + Tailwind v4 + GSAP + Bun. Local lib at `/home/gian/DEV/FACILE/LIB/` as `@facile/lib`.

## Website — facile.studio redesign

### Hero
3D logo tracking cursor movement. 3D dithering effect. Pastel color palette.
Scroll → GSAP animation reveals background + manifesto / CTA (one focus sentence describing Facile).

### Pages
| Page | Purpose |
|---|---|
| **Projects** | Client work showcase |
| **Tools** | Facile internal tools offered to clients as managed architecture (cheaper than other platforms) |
| **Expertise** | How Facile works with a client: brainstorm → understand demand → build → hand over full control + tools |
| **Us** | Team page |
| **Contact** | Contact |

### Client projects (for Projects page)
| Codename | Full name | Notes |
|---|---|---|
| LPB | Les P'tits Bonheurs | Noah's father's restaurant, Phalsbourg |
| — | Le Festival du Théâtre | Signing in ~June 2026 |
| Laura Hervé | lauraherve.com | Portfolio for Lyon graphic designer/artist. Noah's best work to date. |
| Project Zero | — | Branding for friend's modded Minecraft server project |

## Vision

- **Now:** studio-first. Tools exist but are secondary to creative/client work.
- **Later:** split into two entities — saravenpi leads tools/product, Mazouz heads client-facing projects.
- Muse open source → community adoption, brand reach.
- Camille handles visual identity → broader web impact beyond dev tooling.

## Status (2026-05-17)

- **facile.studio** — redesign in progress. Target: Awwwards submission. Concept now crystallizing (see below).
- **Muse** — intentionally slowed. Noah wants it to really stand out visually — reference: [Ron Design Lab](https://rondesignlab.com) aesthetic direction. Goal: a library that doesn't need revisiting for months. Durability over speed.
