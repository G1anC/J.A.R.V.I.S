---
name: facile-review
description: Review code in a Facile suite repo against generic review standards PLUS the suite conventions — the porte/auth security floor, the filet gate, backend file architecture, muse/UI, event contracts. Use when reviewing ANY code under ~/Projects/Facile/Code/ in a suite repo (Sablier, Nuage, Casier, Plume, Courrier, Agenda, Opus, Journal, Capsule, Vision, Glouton, Ardoise, MonorepoBoilerplate, GoSvelteBoilerplate, porte, tronc, caisse, muse, enveloppe, pool). NOT for Grimoire or client vitrines — those get /review. Also runs on "/facile-review".
triggers: ["/facile-review"]
source: "own work root + ~/Code/Facile/Wiki/HARMONIZATION.md + ~/mycelium/memory conventions/bugs + ~/Projects/Facile/Code/CLAUDE.md"
allowed-tools: Bash, Glob, Grep, Read, Edit, Write
---

# facile-review — Facile suite code review

The generic spine (process, severity labels, output template, mindset) applies — if `review.md` is not already in context, read `~/.mycelium/skills/review.md`. This skill ADDS the suite layer and OVERRIDES generic advice on specific points (override table below). One command, three passes:

```
Pass 0: filet gate        (MANDATORY)
Pass 1: generic spine     (review.md process)
Pass 2: suite overlay     (reconcile + suite-only checks)
```

## Scope guard (first)

Suite repo = under `~/Projects/Facile/Code/`, or module path / remote matches `github.com/FacileStudio/`. If NOT: say "not a suite repo — running generic review instead" and follow `review.md`. **Grimoire is explicitly NOT suite** (personal, `github.com/saravenpi/grimoire`) — it gets `/review`.

## Pass 0 — filet gate (MANDATORY)

Run `filet check <path>` (see `~/.mycelium/skills/filet.md` for flags/formats). `.filet.yml` is authoritative and walks up to the repo root. Report findings grouped by rule id, then triage: which are real, which are false positives. **Never suggest raising a threshold or adding to `disabled:` as the fix** — that is the failure mode filet exists to prevent. `arch.*` findings are architecture violations, not nits — never disable them. Also run `filet test` if a suite is present.

## Pass 1 — generic spine

Full review as `review.md`: scope → context → design → line-by-line → summary. Read the language reference for the stack.

## Pass 2 — suite overlay

### Override table — generic advice that does NOT apply

| Generic advice | Suite reality (wins) |
|---|---|
| "Prefer bearer tokens / Authorization header first" | porte reads the **cookie before** the Authorization header. A cookie-authenticated **mutating** request without `X-Facile-CSRF` gets 403. Adding `credentials: 'include'` without the header = every write 403s while reads work — ships green to prod invisibly (bearer tests are exempt by design). Verify with the transport the browser uses, not a real credential. |
| "Extract the duplicated code" (DRY) | Per-app user tables and the porte OIDC adapter are **deliberately duplicated** — the suite is standalone islands by product promise, and the shared auth package hasn't landed. Only the OIDC client adapter is a sanctioned extraction candidate. Do NOT flag deliberate duplication; DO flag genuinely new duplication. |
| "No new dependency" | porte / caisse / tronc / muse / enveloppe / pool are **REQUIRED** infrastructure — hand-rolling auth to avoid a dep is the anti-pattern. The no-dep principle applies only outside the blessed set. |
| "Favor approving, don't demand perfection" | Still true generally — EXCEPT anything touching auth/identity: there, **"not being able to verify is a reason to refuse"**. Security floor beats approval bias. |
| "Add golangci-lint / stricter eslint" | **filet is the suite gate.** Two linters = conflicting authority. Don't. |
| "versioned migrations are optional" | **There are still no versioned migrations in most Go apps** — that's a known structural risk, not a settled design. A change that *removes* or *skips* the goose setup is a regression, not a cleanup. |

### Auth floor (porte) — hard gates

Anything touching auth/identity: check the known bug classes first. Wiki: `~/.mycelium/memory/bugs/porte-*.md`, `~/.mycelium/memory/conventions/facile-suite-auth.md`.

- Cookie-authenticated mutations REQUIRE `X-Facile-CSRF`. Verify with the browser's transport, not a bearer token.
- Authentik's built-in `email` scope mapping returns `email_verified: false` **HARDCODED** — email-based account adoption can never fire on it. Before any backfill plan, check `SELECT count(*) FILTER (WHERE oidc_subject IS NULL) FROM users`.
- A refusal must cost what the acceptance costs (no early return before the argon2 hash — timing oracle).
- porte version floor: **v0.2.10** on apps that mint named API tokens (`Issue`); **v0.2.8** elsewhere (no `Issue` call sites). Never below v0.2.3 (account takeover fixed there).
- `POST /auth/logout` idempotent (v0.2.8+): a stale cookie must still clear.
- SSO_ONLY apps: a refused login and a success are **BOTH a 302** — read `Location`, not the status code; the `error` param must render outside any `SSO_ONLY` gate.

### Backend file architecture (Go family) — hard layout checks

- Layout `apps/api` + `apps/client`; **no** `packages/`. Module path `github.com/FacileStudio/<repo>/apps/api` — a fork that inherited bare `module api` is a bug.
- Migrations: `apps/api/migrations/00001_*.sql` + `migrations.go` with `//go:embed *.sql` at **package root**, as its **own** package (not `package main` — test packages can't reach it otherwise). Sequential goose numbering (`goose -s create`). Never hand-create the `goose_db_version` table; baseline = let goose create it, then `INSERT` the version.
- `main()`: `func main() { os.Exit(run()) }` with `run() int` — a bare `return` from main exits **0** and reads as a clean shutdown to Docker/Dokploy. A failed migration must exit 1.
- `db.DB()` is called ABOVE `schemas.Migrate` (all nine originally had it below).
- Router (chi): `router.Route("/api", ...)`, SPA catch-all registered **LAST** (anything after is unreachable), `CLIENT_DIR=/client` explicit (distroless WORKDIR trap), `PORT` pinned in compose.
- No `gorm.io/driver/sqlite` (or mysql/sqlserver/clickhouse) in go.mod — the `scripts/check.sh` gate. A GORM `default:` tag differing from the Go zero value = silent data bug (the burn-after-read class).
- `scripts/check.sh` exists and passes.
- Go version: go.mod and builder image match (`golang:1.24-alpine` vs go 1.24; goose floor is 1.25).

### TS family checks

- Turborepo `apps/*` + `packages/*`; bun runtime; Hono + tRPC 11 backend, SvelteKit 5 client, Prisma.
- **zod major split**: don't introduce a v4 dep into a v3 repo (it blocks the shared contract package).
- Svelte 5 runes; no legacy stores.
- Client base URL relative (`/api`) — never absolute; the `/api/api/...` double-prefix bug class.

### UI layer (muse)

- Tokens, not hex (`bg-fc-bg`, `text-fc-fg`...); never hardcode a color.
- Svelte 5 runes; no `export let`.
- GSAP + `prefers-reduced-motion`; mobile-first 360px; hit targets ≥44px.
- Cross-platform client: never hover-only affordances (Capacitor ships the same markup, hover is untouchable).

### Events / interop

- Event envelope contract = `@facile/events` (enveloppe); events key on `actor_email` — apps that can't supply it (Grimoire, Capsule, Perception) are known gaps, not new bugs.
- Cross-repo deps via `github:FacileStudio/<repo>#<branch>`; no new registries.

### Deployment shape (only if infra files are in the diff)

- One container, one router, one hostname per app. `expose` not `ports`. No `PathPrefix`/`stripprefix` (mono-container form).
- Compose labels REPLACE Dokploy's — don't add labels to a panel-routed service.
- `/api/health` green says nothing about the front — a deploy check must load the page + a real asset (see `GoSvelteBoilerplate/scripts/verify-deploy.sh`).
- Before deleting a hostname: grep deployed env vars (`OIDC_REDIRECT_URL`, `*_URL`), not just code.

## Documentation sources (link, don't re-derive)

- Wiki conventions: `~/.mycelium/memory/conventions/{project-architecture, facile-go-migrations, facile-backend-exposure, facile-suite-auth, facile-docs-standard}.md`
- Audit + roadmap: `~/Code/Facile/Wiki/HARMONIZATION.md`, `~/Code/Facile/Wiki/ROADMAP.md`
  (local only since 2026-08-22 — the GitHub repo was deleted; migration into mycelium pending)
- Bugs: `~/.mycelium/memory/bugs/porte-*.md`
- Suite catalog + gotchas: `~/Projects/Facile/Code/CLAUDE.md`

## Output

Same template as `review.md`. Label suite-specific findings with their layer, e.g. `🔴 [auth]`, `🟡 [arch]`.