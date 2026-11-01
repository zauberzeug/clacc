---
type: behavior
tags: [macos, tokens, safety]
status: active
---

# Keychain writes are read back

The Keychain has no atomic rename, so clacc removes the old item only once the new one reads back the same.
A write that does not read back stops the command with exit 1, and no login is lost.

A login goes to `security -i` on its standard input, where no other process can see it.
`security -i` cuts a line beyond 4 KB and stores the rest.
So a longer login, as one with MCP sign-ins often is, goes on the command line, where other processes on the machine can read it for a moment.

`security` prints a value with non-ASCII characters as hex, and clacc reads it back as text.
