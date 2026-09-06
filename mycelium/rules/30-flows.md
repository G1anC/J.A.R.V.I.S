## Flows

A flow is a recorded procedure: an ordered list of shell steps in `~/.mycelium/flows/`, run
by `mycelium flow run <name>` (or the `run_flow` tool, if you have it), which writes a JSON
artifact of every execution. Flows sync
across machines like the rest of `~/.mycelium/`; their run artifacts never leave the machine
that produced them.

The wiki and flows split the same knowledge. The wiki holds **why**: judgment, context,
the gotcha that explains the shape. A flow holds **what**: the exact steps, in order, that
already worked. Prose you must re-reason from is not a procedure. Steps with no explanation
are not memory. Write both, and link them.

### The flow gate

Write a flow when ALL of these hold:

1. **You ran it and it worked.** A flow is a recording, never a guess. Never write one for
   steps you have not executed.
2. **It will run again.** Recurring work, or work another machine will need. A genuine
   one-off is not a flow; just do it.
3. **It is deterministic.** Same steps, same result. Work that needs a judgment call at
   each run belongs in a skill, not a flow.

If any answer is no, skip it. A flow nobody runs twice is worse than no flow, because the
next agent trusts it and it has quietly rotted.

### Notice the repetition

You will not be told "make a flow". Spotting the moment is your job, and there are three
signals, in order of how often they fire:

1. **You are about to run a sequence you already ran this session.** Two runs of the same
   three-plus commands is not a coincidence, it is a procedure.
2. **The wiki documents the steps in prose.** A page that says "run X, then Y, then Z" is
   a flow that was written down in the wrong format. Convert it and link the page.
3. **You are re-deriving.** If you find yourself reading a repo to work out how it is
   built, tested or deployed, and the answer turns out to be commands somebody already
   knew, that answer belongs in a flow so nobody pays for it a third time.

When a signal fires, say so and offer the flow. Do not silently write one mid-task and do
not silently skip it either. The human decides, but you raise it.

### Look before you write

Run `mycelium flow list` before creating anything. Reuse or extend an existing flow rather
than adding a near-duplicate under a different name. The same rung of the ladder that
applies to code applies here. Two flows that half-overlap is how this store turns into the
`deploy-final-v2-REAL.sh` folder it exists to replace.

`mycelium flow list --json` and `mycelium flow runs <name> --json` are the machine-readable
forms. Use them; parse the human output of nothing.

### Writing one

Scaffold with `mycelium flow add <name>`, then fill it in. The file's `name:` must match its
filename, unknown fields are rejected, and every step needs a `name` and a `run`.

**`run:` is a launcher, not a program.** Steps execute through `sh -c`, and `/bin/sh` is
dash on ruche and bash 3.2 on lucy, so `[[ ]]`, arrays, `local` and `set -o pipefail`
break on one machine or the other. Keep `run:` to a single invocation and put the logic in
a TypeScript file run by bun:

```yaml
steps:
  - name: sync-check
    run: bun ~/.mycelium/skills/scripts/sync-check.ts
```

Anything with branching, JSON or error handling goes in that file, which also makes the
step runnable outside mycelium when it breaks at 2am.

**A step can read an earlier step's output.** `needs` binds an environment variable to
`<step>.<field>`, where field is `stdout`, `stderr` or `exit_code`. Quote the reference in
`run:`. The value is data, never program text, and nothing is ever spliced into the string
handed to `sh`:

```yaml
steps:
  - name: version
    run: git describe --tags --always
  - name: notify
    needs:
      VERSION: version.stdout
    run: bun ~/.mycelium/skills/scripts/notify.ts "$VERSION"
```

Only backward references, only those three fields, and a chained value is capped at 64KB.
Anything bigger goes in a file and you pass the path. `needs` requires mycelium v0.13.0+ on
every machine that runs the flow; an older one refuses the file as invalid.

**Steps run in file order unless you say otherwise.** Declaring `depends_on`, even as an
empty list, opts a step into the dependency graph, and steps with no edge between them run
at the same time. Needing an output is already a dependency, so `needs` and `depends_on`
cannot disagree. A failed step blocks its dependents; independent branches finish.

```yaml
steps:
  - name: lint
    depends_on: []
    run: mise run lint
  - name: test
    depends_on: []
    run: mise run test
  - name: deploy
    depends_on: [lint, test]
    run: ./deploy.sh
```

`ephemeral: true` keeps a step's output out of the artifact while still passing it on.
`mycelium flow query --status failed --since 7d` answers across every flow at once. A step may
also declare `type:` to run a model extension (TypeScript, run by bun) instead of a shell
command. Those are trusted per machine like flows, via `mycelium flow trust-model`. All of
this needs v0.14.0+ everywhere the flow runs.

**Verify before you destroy.** A step that deletes, overwrites, drops or force-pushes must
be preceded by a step that confirms the target is what you think it is. A flow runs
unattended by design; nobody is watching to stop it.

**Never put a secret in a flow file.** Flows sync. Read credentials from the environment at
run time. Values of environment variables named like secrets are masked in the artifact,
but a literal pasted into `run:` is committed, synced, and yours forever.

### Expect the refusal

A flow you write will NOT run. It lands untrusted, and `mycelium flow run` refuses it before
executing a single step, because content that arrives over sync must be approved on the
machine that will run it.

This is the design, not a bug. Do not route around it, do not reach for the shell to run
the steps by hand instead. Tell the human what the flow does and ask them to review it and
run `mycelium flow trust <name>`. The same refusal appears after any edit, including yours.

`mycelium flow list` shows `not pinned` for a flow awaiting first approval and `CHANGED` for
one edited since. `CHANGED` on a flow you did not touch is worth raising, not clearing.

### After a run

`mycelium flow show <name>` prints the last run: per-step exit codes, durations and output.
Read it rather than re-running to see what happened. If a flow failed for a reason worth
keeping, the reason goes in the wiki and the fix goes in the flow.
