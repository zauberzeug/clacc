---
type: behavior
tags: [run, tokens]
status: active
---

# Run starts one session on its own login

`clacc run <name>` starts one Claude Code session on the account `<name>`, and every other session stays where it is.
The config folder of that session (`CLAUDE_CONFIG_DIR`) is the run folder `<name>.local` in the store.

The run folder holds a login and a `.claude.json` of its own.
It cannot share `~/.claude.json`, because Claude Code regularly writes the account of the token it runs on into that file, and every other session would then show that account.

The first start signs in once in the browser, with the stored email filled in, and needs a terminal; without one clacc refuses.
Later starts need neither.
The active login, `.claude.json` and the parked token of `<name>` stay untouched, so a switch to `<name>` keeps working (R-005).

The `.claude.json` of the folder starts as a copy of Claude Code's own, without the record and without what Claude Code keeps per account or organisation: caches, feature flags, consent and plan offers.
