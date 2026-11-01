---
type: behavior
tags: [config]
status: active
---

# clacc follows CLAUDE_CONFIG_DIR

When `CLAUDE_CONFIG_DIR` names a folder, that folder is Claude Code's folder, with the login and `.claude.json` inside it, and clacc works on it.
Without that variable, Claude Code's folder is `~/.claude` and the config file is `~/.claude.json`.

Inside a `clacc run` session `CLAUDE_CONFIG_DIR` names the run folder.
So `CLACC_CLAUDE_CONFIG_DIR` keeps what the caller had, and clacc inside that session still sees the folder it came from.
A run folder alone in `CLAUDE_CONFIG_DIR`, as in a helper spawned without that second variable, means the default folder.

clacc unsets `CLAUDE_SECURESTORAGE_CONFIG_DIR`, which would move the token folder of every claude it starts.
