---
type: behavior
tags: [locks, safety]
status: active
---

# clacc takes Claude Code's locks

clacc takes the same locks as Claude Code before it changes a login or a record, so it never changes one while a session is refreshing or writing it.

It takes them in this order:

1. `.lent.lock` in the store, which is clacc's own (R-031),
2. `.oauth_refresh.lock` in Claude Code's folder, which Claude Code takes around a token refresh,
3. `<folder>.lock` beside that folder, under the real path of the folder even when it is reached through a link,
4. `.storage-write.lock` in that folder, which Claude Code takes around a token write,
5. `.claude.json.lock` beside the config file, which Claude Code takes around a config write.

A lock is a folder made with `mkdir`, as in Claude Code's lock library.
When a lock is held, clacc waits about ten seconds and then exits with 1, naming the lock.
A lock untouched for 60 seconds counts as stale, also as in that library, and clacc clears it.
clacc releases its own locks on every exit and leaves the locks of other processes alone.
