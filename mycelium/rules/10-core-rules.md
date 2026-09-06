## Core Rules

### Communication Mode

Write to **ISO 24495-1** (plain language): the reader gets what they need, finds it easily,
understands it, and can act on it. Note that ~93% of that standard is about structure and
findability, not word choice, so fixing a dense answer usually means reordering it, not
shortening the words.

- Lead with the answer, then the reasoning. The reader should be able to stop after one paragraph
- One idea per paragraph. Short sentences. Ordinary words
- Prefer the plain word over the jargon one; define a term the first time it is needed
- Cut what the reader does not need. Length is not thoroughness, and neither is compression
- Make it skimmable: a heading and a first line should say what the section is for
- Keep code, commands, file paths, logs, error text, and quoted content exact
- No filler, no pleasantries, no restating the question back. Do not strip grammar to save words

#### No slop

Applies to every reply, commit message, PR body, wiki page, and document you write. The rules
above say what to write; these are the tells that survive them.

- No em dashes. End the sentence or use a comma. Do not substitute parentheses, en dashes, or a
  hyphen standing in for a dash, that trades one tell for another
- No decorative emoji in headings, bullets, or committed prose. Severity markers a skill defines
  are functional, not decoration
- State the point directly. No "it's not just X, it's Y", no hedge stacks ("could potentially
  possibly be argued" is "may"), and no forcing ideas into threes when the real number is two
- End on a fact, a number, or the next step, never on a generic closer
- Sentence case headings, straight quotes
- Name the actor: "the compiler validates queries", not "queries are validated". Passive is for
  when the actor is unknown or genuinely does not matter
- Say the concrete thing. If a sentence cannot be restated as a fact, an instruction, or a
  number, cut it. "the database stays close at hand" is a feeling, "`.toSQL()` returns the exact
  string sent to the database" is the mechanism
- `harness` and `surface` are exempt from the plain-word rule above, they name real things here

For a deliberate pass over an existing document, run `/unslop`.

### Git & Version Control

- NEVER add "Generated with Claude Code" to pull requests
- NEVER add "Generated with Codex" to pull requests
- NEVER prefix branches with `claude` or `codex`
- NEVER add co-author attribution to commits
- Use `gh` CLI for all GitHub operations
- Commit subjects follow Conventional Commits: `type(scope): summary`, imperative, lowercase, no trailing period, under 72 characters
- Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `style`, `test`, `build`, `ci`, `chore`, `revert`
- Scope is the package or directory touched; omit it rather than invent one
- Breaking changes get `!` after the type and a `BREAKING CHANGE:` footer
- NEVER write a gitmoji in a commit message; the `commit-msg` hook derives it from the type

### Code Style

- Comments are capped at 2 lines. A comment that needs a third is a sign the code needs a
  better name or a smaller function, so fix that instead of writing the paragraph
- Comment why, never what. The code already says what it does
- The cap covers comments in code. Doc blocks in the language's native format above a public
  function (JSDoc, rustdoc, docstring, godoc) are documentation and run as long as they need
- When developing Rust, remove dead code

### Engineering Ladder

From [ponytail](https://github.com/DietrichGebert/ponytail). Understand the problem first: read the
task and the code it touches, trace the real flow end to end, *then* climb. The ladder runs after
understanding, not instead of it.

Stop at the first rung that holds:

1. Does this need to exist? (YAGNI: if no, stop)
2. Does it already exist in this codebase? Reuse the helper, util or pattern that is already here
3. Does the standard library do it? Use it
4. Does a native platform feature cover it? Use it
5. Does an already-installed dependency solve it? Use it
6. Can it be one line? Make it one line
7. Only then: write the minimum that works

- Deletion over addition. Boring over clever. Fewest files possible
- Shortest working diff wins, but only once the problem is understood. The smallest change in the
  wrong place is not lazy, it is a second bug
- Fix the root cause, not the symptom. A report names a symptom; grep every caller and fix the
  shared function once, rather than patching the one path the report happened to name
- No abstractions that were not asked for. No boilerplate nobody asked for
- No new dependency if it can be avoided
- Question complex requests: "Do you actually need X, or does Y cover it?"
- Lazy is not flimsy: when two approaches are the same size, pick the edge-case-correct one
- Never lazy about: understanding the problem, input validation at trust boundaries, error handling
  that prevents data loss, security, accessibility, or anything explicitly requested
- Non-trivial logic gets one runnable check, the smallest thing that fails if the logic breaks. No
  frameworks, no fixtures. Trivial one-liners need no test

### Machine-local profile

Author name, machine names, SSH aliases, infrastructure endpoints and second-brain paths are
per-machine and never published. They live in `~/.agents/AGENTS.local.md`, which is gitignored.
Claude Code resolves the import below; Crush loads the same file via `global_context_paths`.

@~/.agents/AGENTS.local.md

If that file is absent this config still works, the agent simply has no infrastructure context.
