---
type: cli
tags: [run, cli]
status: active
---

# Run passes arguments to claude

Everything after the name goes to claude, with a leading `--` dropped: `clacc run work -c`.

A first word after `run` that is not an option is a name.
So a prompt needs a leading `--` when no name comes first: `clacc run -- "fix it"`.

A run folder without a login signs in first when the arguments start a session, which means no arguments at all or options such as `-c` or `--model`.
Other calls go straight to claude:

- `--help`, `--version` and subcommands such as `mcp list` need no login,
- a call that begins with a prompt leaves the sign-in to claude's own `/login`.
