# Security review reference

Cross-cutting checklist, trimmed from awesome-skills/code-review-skill (MIT) + OWASP. Facile suite: auth/identity is governed by the porte floor in facile-review — read that first when the diff touches auth.

## Input validation

- Every input boundary validated: HTTP params, JSON body, query strings, file uploads, CLI args.
- Size limits on bodies/uploads; type coercion explicit (no truthy-string traps).
- Server-side validation on every mutation — client-side is convenience, not security.

## Injection

- SQL: parameterized queries / ORM — never string-concatenated values. Dynamic identifiers (table/column names) need an allowlist, not escaping.
- Command injection: `exec` with user input is a finding; use `exec.Command` (no shell) and argument arrays.
- No `eval` / `Function()` / template-string code on untrusted input.
- SSRF: URLs fetched from user input must be allowlisted by scheme/host; no creds in URLs.

## AuthN / AuthZ

- Every route that touches a resource checks authorization, not just authentication.
- IDOR: object IDs from the request must be checked against the session's ownership (Facile: user-scoped resources; `actor_email` keying).
- Secrets: never in code, ENV, ARG, or committed files; `.env` gitignored; tokens generated with `crypto/random`, never `math/random`.
- Password storage: argon2id (Facile porte floor) — never bcrypt-on-steroids hand-rolls, never plaintext, never reversible.
- Timing: auth refusals should cost what acceptances cost (no early-return before the hash — the registration timing-oracle class).

## Web

- XSS: output-encoded, no `v-html`/`innerHTML` with user data; Svelte escapes by default — flag `{@html}`.
- CSRF: Facile = `X-Facile-CSRF` on cookie-authenticated mutations (porte reads cookie before Authorization header).
- CORS: narrow origin, credentials handling explicit; `*` only where the endpoint is public by design (Vision collector).
- Redirect: open-redirect guards on login/callback URLs — validate the `redirect`/`return_to` param against allowed origins.
- Cookie flags: `HttpOnly`, `Secure`, `SameSite=Lax/Strict` on session cookies; no tokens in URLs (Facile: OIDC rides the URL **fragment**, never `?token=`).

## Data

- Sensitive fields redacted in logs (emails partial, tokens never).
- File uploads: extension+content sniffing, size caps, stored outside the web root, served with `Content-Disposition` where apt.
- Backup/export paths don't leak other tenants' data (scoping bug class).

## Dependencies

- No pinned vulnerable versions; no `latest` tags; supply-chain: lockfiles committed.
- New deps: checked for maintenance status and license before accepting (Facile: prefer the blessed set — porte/caisse/tronc/muse/enveloppe/pool).

## Docker

- Unpinned `FROM`, root user, secrets in ENV/ARG, missing HEALTHCHECK, missing .dockerignore — all findings (filet `docker` covers these deterministically; run it).