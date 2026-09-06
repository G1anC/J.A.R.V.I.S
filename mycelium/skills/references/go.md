# Go review reference

Trimmed from awesome-skills/code-review-skill (MIT) + Facile suite observations. Read per review, not line by line — scan for what matches the diff.

## Errors

- Never ignore errors; a bare `_` discard needs a one-line justification.
- Wrap with context: `fmt.Errorf("loading user %d: %w", id, err)` — never `%v` (breaks the chain), never bare `return err`.
- Compare with `errors.Is`/`errors.As`, never `==` against a sentinel that may be wrapped.
- Distinguish "can't happen" panics from recoverable errors. No `panic` in library code.

## Concurrency

- Every goroutine needs an exit: context cancellation or channel close. A goroutine started in a request handler must not outlive the request's context.
- Prefer `errgroup` over hand-rolled WaitGroup+error plumbing.
- Shared state: mutex covers the write AND the read (no TOCTOU on map access), or use sync.Map / atomic.
- Channel sends: ensure the receiver exists; closing a channel while senders live panics.
- `select` with `ctx.Done()` on every blocking op that should be cancellable.

## Context & lifecycle

- `context.Context` is first parameter by convention; never stored in a struct where a value would do.
- Timeouts: `http.Server` with ReadHeaderTimeout; DB calls with `context.WithTimeout`.

## Types & nil

- Pointer receiver mutates; value receiver for immutable. Mixed receivers on one type = smell.
- nil map read ok, nil map write panics. nil slice is fine; `append` to nil works.
- Interface holding a typed nil (`var x *T = nil; var i any = x`) — the classic nil-check trap.

## Go-specific gotchas

- Loop variable capture pre-1.22: `for _, v := range` + goroutine closure captures the loop var.
- Shadowing: `:=` inside an inner block silently shadows — flag when the outer value was intended.
- `defer` in a loop accumulates until function return; close/consume inside the loop.
- `time.After` in a loop leaks a timer per iteration.
- String/byte conversions in hot paths; `fmt.Sprintf` in loops.
- JSON: exported fields only, tags where the wire shape differs; `json.RawMessage` for passthrough.

## Testing

- Tests actually assert something (`if got != want`), not just "no panic".
- Table-driven where the shape repeats; t.Run subtests.
- No sleeps for synchronization — use channels/waitgroups/`testing.Short` guards.
- Facile: Postgres tests via `tronc/testdb`; never sqlite (see facile-review auth/arch checks).

## Facile suite extras

- Module path `github.com/FacileStudio/<repo>/apps/api` — bare `module api` is a fork bug.
- `func main() { os.Exit(run()) }` — bare return exits 0 (clean shutdown to Docker), a lie on failure.
- `db.DB()` above `schemas.Migrate`; migrations in their own package with `//go:embed *.sql`.
- `run()` returning error must be `os.Exit(1)`-wired; a failed migration must stop the deploy.
