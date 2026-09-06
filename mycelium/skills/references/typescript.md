# TypeScript review reference

Trimmed from awesome-skills/code-review-skill (MIT). Facile TS family runs bun + Turborepo; backend is Hono + tRPC 11.

## Types

- No `any` escaping — `unknown` for unparsed input, narrow with guards. `any` in a public API signature is a finding.
- No `@ts-ignore` / `@ts-expect-error` without a reason; they rot when the underlying issue is fixed.
- `as` casts: flag downcasts that skip a runtime check (JSON parsing, API responses) — validate first.
- Avoid `!` non-null assertions where a guard would do; prefer `??` defaults.
- Enums vs union types: string unions are usually the better call for wire data.

## Async

- No floating promises — every async call is awaited or `.catch`-ed; flag unhandled rejections.
- `Promise.all` over sequential awaits when independent; beware `Promise.all` unhandled rejection on the rest.
- Async generators/streams: drain or cancel; no leaks in long-lived loops.

## Hono + tRPC specifics

- tRPC: input validation via zod on every mutation/query — unvalidated input is a finding.
- Hono middleware order matters: auth before handlers that need it; error handler last; CORS configured narrowly (Facile: single app origin, except Vision's `/api/e/` which is deliberately `*`).
- Route prefix: `/api` group, relative client base URL (Facile mono-container).

## SvelteKit-adjacent

- Server-only secrets never imported into client code (`$env/static/private` vs `$env/static/public` — the public one is in the bundle).
- `+server.ts` routes that proxy: forward method, headers, and errors — a swallowed status is a bug.

## General

- No dead code, no commented-out blocks; unused imports/exports flagged.
- `package.json`: pinned or semver-range deps that match the repo's convention; no accidental `workspace:*` cross-repo leakage.
- Facile: zod major must match the repo's existing major (v3 vs v4 split — mixing blocks the shared contract package).

## Testing

- Tests assert behavior, not implementation; no snapshot sprawl (each snapshot read-worthy).
- msw/vitest: mock at the boundary, not deep inside; no `vi.spyOn` on internals that makes the test meaningless.