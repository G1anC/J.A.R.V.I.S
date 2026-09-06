## Wiki

Persistent agent memory lives in `~/.mycelium/memory/` and syncs across every machine and
agent via the `mycelium` CLI. This file is policy, not knowledge. Put durable facts in the
wiki, not here. Treat `~/.mycelium/memory/` as the canonical wiki root regardless of `pwd`.
Skills and personas may add task-specific instructions but must not contradict this file.
Query and write silently; the wiki is infrastructure, not conversation.

### Non-negotiable: read first, write back

The wiki only earns its keep if you use it. Two actions are mandatory by default, not
optional extras:

- **Start gate.** Before your first real tool call on a non-trivial task, read
  `overview.md`, then search. Syncing is not your job: a daemon reconciles every 60s and a
  hook freshens memory before a search. Skipping
  this because the task "looks small" is the single most common failure. Small tasks are
  exactly where a stale assumption or a past gotcha bites. Default to running it; justify
  *not* running it, never the reverse.
- **End gate.** A task is not done until the wiki reflects what you learned. Before
  ending any task that produced something durable (a fixed bug, a non-obvious flag, a
  project gotcha, a resolved design call), write it back through the Storage gate.

**Non-trivial** = anything past a single conversational reply or a one-line mechanical edit
you could make blindfolded. Touching code, config, infra, or deploys, and answering
"how/why/where does X work" about a project, all count. Unsure? Assume non-trivial and run
the start gate. It costs seconds, and the storage gate still stops noise from being
written back.

### Operating loop

On any non-trivial task:

1. Read `~/.mycelium/memory/overview.md`.
2. Search before rediscovering, and skim the relevant section of the index.
<!-- agent:mcp -->
   Call `search_memory` with the keywords. Prefer it over grepping the wiki: it ranks, and it
   reaches the server's hybrid index when that is available.
<!-- /agent -->
<!-- agent:cli -->
   `mycelium memory search "<keywords>"`, and `mycelium memory index` for the index.
<!-- /agent -->
3. Open only the 1-3 most relevant pages.
4. Do the work.
5. If the result is durable and non-obvious, write it back with `mycelium memory add`
   (see Storage gate). It appends the finding, bumps `updated:`, adds the index pointer,
   writes the `log.md` line and pushes, in one call.
6. If new evidence contradicts a page, lint it.

A background daemon syncs every 60s and announces itself when it stops, so there is no sync
step for you to run or forget.

If syncing is failing (offline, sandboxed shell, server unreachable), do not skip the rest
of the loop: memory is local-first. Keep reading, searching, and writing `~/.mycelium/memory/`.
The daemon reconciles once the network is back. A failed sync never excuses a skipped
start gate or end gate.

### Invariants

- `~/.mycelium/memory/` is the only place for persistent memory. Raw sources stay outside it
  and are treated as immutable source material.
- `overview.md` = core memory: always-read, short, cross-cutting. Keep it that way.
- `index.md` = router, one line per page, not a dump.
- `log.md` = append-only; never edit or delete past entries.
- Every non-obvious claim needs provenance: a URL, a file path, or `direct observation`.
- On reversal, mark the old claim `[SUPERSEDED by: source, date]` and log it.

### Layout

```text
~/.mycelium/memory/
├── overview.md   always-read summary (core memory)
├── index.md      one-line-per-page router
├── log.md        append-only history
└── bugs/ tools/ projects/ conventions/ standards/ syntheses/ people/
```

Prefer updating an existing page over creating one. Create a new page only when the topic
is likely to recur or has enough material to stand alone.

### The wiki is English-only

Wiki pages **and the queries you search them with** are English, whatever language the
conversation was in.

This is a retrieval requirement, not a style preference. Agents mostly reason in English, and
an English query does not reach a French page: BM25 cannot match "backups" against
"sauvegardes", and the deployed embedding model (`all-minilm`) is English-only, so neither half
of hybrid search crosses the language boundary. A French page is invisible to half the questions
asked of it, and a French query is invisible to the whole corpus.

- **The corpus was converted on 2026-08-19.** All 41 French pages were translated to English,
  page by page, each batch a reviewable commit. If you find a French page, it is new drift.
  Rewrite it in English as part of whatever edit brought you there.
- **Search in English.** `mycelium memory search "postgres backups on the server"`, never
  "sauvegardes postgres ruche".
- **Keep French where French is the subject**: client-facing content, French administrative or
  legal matter (SIRET, "TVA non applicable art. 293 B du CGI", filed document names), quoted
  text, and identifiers that are French words (`porte`, `caisse`, `enveloppe`). Translating a
  legal string or a package name breaks the thing it names.
- **Never translate the exact parts**: commands, file paths, error strings, code, log lines.

**Enforced mechanically, in one place.** `mycelium doctor` reports a `wiki language` check that scans
every page line by line, and `mycelium sync` warns about French in the pages it just moved. Run
`mycelium doctor` after any session that wrote to the wiki. Two escapes, both narrow: `log.md` is
exempt because it is append-only, and a line carrying `<!-- lang:fr -->` is exempt. Use that for a
verbatim quotation or a French legal string, never to postpone a translation.

There is deliberately no second implementation. An earlier TypeScript copy of this rule diverged
from the Go one within a day, with different word lists and different tokenisers. The TS tokeniser
counted identifiers and URLs as prose words, which inflated the denominator until four French index
hooks scored below the threshold and were reported clean. If you need this in another language,
shell out to `mycelium`.

**The wiki is single-language by decision.** English is not the default among several, it is the
only one. Do not add language detection, per-language indexes, translated duplicates, or a
multilingual embedding model to serve French pages. There are none, and reintroducing one is a
regression the check will catch. The retrieval stack assumes one language and is measured that
way: cross-language recall@5 went 0.500 → 1.000 when the corpus converged on 2026-08-19.

### Storage gate

Write only when ALL hold:

1. The fact will change how a future agent acts.
2. It is non-obvious or annoying to rediscover.
3. It is grounded in a source, documentation, or direct observation.
4. It carries no secret. Credentials, tokens, API keys, passwords and private keys are
   refused whatever the first three say: the wiki syncs to every machine and every agent,
   and a page is retrieved into a context window by design.

If any answer is no, skip. Typical triggers: a bug fixed via docs or trial-and-error, a
non-obvious tool flag, a project gotcha, a resolved style/architecture call, or a synthesis
worth keeping. Never store: secrets, facts obvious from current code, re-runnable command
output, git history, ephemeral session state, easily-rediscovered generic docs, or
anything already in the rules. Test: "Will this save real time in a future session with no
memory of today?" If no, let it die with dignity.

### Retrieval

Budget: `overview.md` + the relevant `index.md` section + up to 3 pages. Expand with local
search (`rg`, `mycelium memory search`) only if that is not enough. Do not load the whole wiki.
Once the wiki passes ~100 pages or the index ~200 lines, lean on search over index-scanning.

| Situation | Read |
|---|---|
| Fixing a bug | `bugs/` + `index.md` |
| Using a tool for non-trivial work | `tools/<tool>.md` |
| Starting in an unfamiliar repo area | `projects/<project>.md` |
| Style or architecture question | `conventions/` |
| Working with an external contact or client | `people/<person>.md` |
| Might already be solved | `index.md`, then syntheses / topic pages |

If the wiki has no relevant entry, proceed without it.

### Page frontmatter

Every page except `index.md` and `log.md` carries:

```yaml
---
title: Short descriptive title
type: bug | tool | project | convention | standard | synthesis | person
sources: [URLs, files, or docs consulted]
related: [other wiki pages linked]
confidence: high | medium | low
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Use `confidence: high` only when verified; lower it or skip the claim if provenance is
incomplete. Do not invent line numbers or sections you did not check. Link related pages
with `[[page-name]]`.

`type: standard` marks a normative page, and those live under `standards/`. Every other type
is descriptive: a dated observation an agent filed, which you lint freely when better
evidence turns up. A standard says the opposite direction, "when a repo disagrees with this,
the repo is wrong", so it is not yours to correct from one session's evidence. Propose the
change to the user; do not silently rewrite a normative page.

**A normative page is ratified per machine, and an unratified change is visible.** A human
runs `mycelium memory ratify <page>` to accept a standard at the content they read. If the page
changes afterwards, `mycelium doctor` fails and every search result from it prints
`[changed since ratified]` until a human reads the new version and ratifies again.

What that means for you, in three lines:

- **Never run `mycelium memory ratify` or `mycelium memory forget`.** Ratifying is the human
  saying they read it. An agent ratifying its own edit is the signal deleting itself.
- **A `[changed since ratified]` result is not authoritative.** Read it, but do not treat it
  as settled and do not build an argument on it. Say the page is in that state and ask.
- If you believe a standard is wrong, say so and cite the source. That is the whole of your
  role here.

Ratification never blocks anything: the page still syncs, still exists and still ranks. Only
its authority is in question, never its availability.

### Writing a finding

Keep entries to 2-6 lines of substance, not a diary. Format:

```markdown
### <short title>
**Date**: YYYY-MM-DD
**Source**: <URL | file path | "direct observation">
<what was learned, why it matters, and how it should change future behavior>
```

`mycelium memory add <page> --title <t> --source <s> --body-stdin --log <what changed>` does
the bookkeeping: the finding, the `updated:` bump, the index pointer, the `log.md` line and the
push. Editing an existing page, and linting one, stays an ordinary file edit. File longer
analyses to `syntheses/<name>.md` and link them from related pages.

**When you re-check an existing finding and it still holds, stamp it.** Put a
`<!-- confirmed: YYYY-MM-DD -->` line directly under that finding's `###` heading, with
today's date, and nothing else in the comment. Ranking reads it as the date the claim was
last known good, so a re-verified claim stops decaying like a page nobody has looked at
since it was written. Update the date on a later re-check; do not add other fields. A new
finding never carries it: the field means "someone checked this again", and stamping one you
just wrote makes the signal worthless.

### Log format

Every wiki write appends one line to `log.md`:

```text
## [YYYY-MM-DD] <operation> | <short description>
```

Operations: `create-page`, `ingest`, `query-filed`, `lint`, `supersede`.

### Lint

Lint a page when new evidence contradicts it, it has gone stale, it keeps getting touched
without cleanup, or on request. Fix the page in place: read it fully, remove stale or
duplicate claims, mark superseded ones, add missing cross-links, update frontmatter, and
append a `lint`/`supersede` line to `log.md`. Never write separate lint-report files.
