# Machine-local profile

Loaded alongside `AGENTS.md`. Copy to `AGENTS.local.md` and fill in. Never committed.

### User Profile

- Author name: `your-handle`
- Preferred task runner: `mise` when available
- TypeScript runtime: `bun`
- Package manager: `bun`

### Infrastructure

- Local machine name: `your-laptop`
- Webserver/VPS nickname and SSH alias, and where to resolve its connection details
- Any deployment CLI that is installed and what panel it authenticates against

### Brain / Obsidian

- `$BRAIN` points to the root of the user's markdown-based second brain
- Resolve the actual path by reading the `BRAIN` environment variable before searching
- Prefer read-only inspection unless the user explicitly asks to write there
