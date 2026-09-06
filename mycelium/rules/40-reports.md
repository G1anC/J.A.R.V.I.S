## Artifacts & Reports

An artifact is a self-contained markdown (.md) or HTML (.html) document recorded with
`mycelium artifact add <file>` (or `--body-stdin`), or via the `publish_artifact` MCP tool.
It lands in `~/.mycelium/artifacts/` and syncs across machines.

When a Mycelium server URL is configured, artifacts are hosted at
`https://<server>/artifacts/<id>` and `mycelium artifact open <id>` opens that URL in the
browser. Hand the reader the canonical web URL.

The wiki and artifacts split the same output. The wiki holds the **fact**, as text, forever.
An artifact holds the **rendered presentation** or structural report, and expires in thirty days
by default (or `--expires never`). A finding filed only as an artifact is a finding nobody can
search: `mycelium memory search` indexes `memory/` and not artifacts.

### The artifact gate

Record one when ALL three hold:

1. **The answer is structural, not linear.** A comparison across many items, a timeline, a
   graph, an extensive report, or a table wider than a terminal. Prose and a terminal table
   cover everything else.
2. **It will be read more than once**, or by somebody who is not in this session.
3. **It is derived from something durable** that already exists or is being written.

If any answer is no, answer in the conversation and stop.

### Rules

- **Never use harness-specific artifacts.** Do not write to harness artifact directories
  (such as Antigravity brain artifacts or Claude Code scratchpads) unless explicitly requested.
  Always record through `publish_artifact` or `mycelium artifact add`.
- **Never instead of answering.** The terminal answer comes first, always. An artifact is an
  attachment to an answer, never the answer itself.
- **Never for a raw finding.** File durable facts with `mycelium memory add`. The artifact
  illustrates or synthesizes findings; it does not replace them.
- **Never unprompted for something that fits on a screen.** Generating a page for a two-line
  answer is noise.

### Writing an artifact

The document carries everything it needs inline. A relative `src` or `href` will not resolve,
so embed assets or use data URIs. `add` warns about unresolved relative links.

The document's title (from frontmatter `title:`, markdown `# Heading`, or HTML `<title>`)
becomes the artifact's identifier. Recording the same title replaces it in place rather than
piling up duplicates.
