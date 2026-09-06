# Svelte / SvelteKit review reference

Trimmed from awesome-skills/code-review-skill (MIT) + Facile suite conventions. Facile targets Svelte 5 + SvelteKit 5.

## Runes (Svelte 5) — the big one

- Prefer `$state`, `$derived`, `$props`, `$effect` over the legacy API.
- No `export let` for props — use `$props()`. No `onMount` where `$effect` fits.
- No legacy stores (`writable`) where a rune fits — but a store is fine when state is shared across components/modules.
- `$derived` must be pure (no side effects); do async work in `$effect` or in a load, not in `$derived`.
- Mutation: reassign or mutate `$state` directly; don't try to mutate a prop.
- `$effect` re-runs on every reactive dependency change — flag effects that run on mount only but list reactive deps (use `untrack` or a guard).

## Load functions & SSR

- `+page.server.ts` / `+layout.server.ts` load: handle errors, never throw raw; return typed data.
- `adapter-static` silently drops every `+server.ts` — check none exist before a static migration, and that `hooks.server.ts` was replaced by `server.proxy` in vite config.
- `ssr = false` / `prerender = false` in `+layout.ts` when the SPA is served by a backend binary (Facile mono-container form).
- Load functions must be cached-friendly; avoid non-deterministic output.

## Form actions & mutations

- Form actions: validate server-side, never trust the client; return `{ error }` vs `fail()` correctly.
- Mutating requests from a cookie-authenticated client need `X-Facile-CSRF` (Facile/porte) — see facile-review auth floor.

## Accessibility & UX

- Buttons over divs; `aria-*` where semantics don't carry.
- Cross-platform (Facile Capacitor/Tauri): no hover-only affordances — actions must be discoverable at rest.
- Focus management on modals/route changes; prefers-reduced-motion honored.

## Facile suite extras

- muse tokens, not hex (`bg-fc-bg`, `text-fc-fg`); read `@facile/muse` exports before hand-rolling a component.
- Client base URL relative (`/api`), never absolute — the `/api/api/...` double-prefix bug class.
- Tailwind v4: `@source` pointed at muse inside node_modules or utilities never generate; `optimizeDeps.exclude: ['@facile/muse']` required in vite dev.