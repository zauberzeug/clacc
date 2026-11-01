---
type: behavior
tags: [macos, tokens]
status: active
---

# Logins stay in the Keychain on macOS

On macOS every login stays in the Keychain and no token lands in a file, because a token beside the Keychain would be less protected than the one in it.

| Login                                                 | Keychain item                     |
| ----------------------------------------------------- | --------------------------------- |
| the active login in the default folder                | `Claude Code-credentials`         |
| the login of a folder named by a path                 | `Claude Code-credentials-<hash>`  |
| a parked token                                        | `clacc <path of its store file>`  |

The hash is the first 8 hex digits of the SHA-256 of the path.
The first two item names are the ones Claude Code itself uses.

The hash takes the path as written, while the lock beside the folder takes its resolved path (R-011).
Claude Code does it this way, so the two must not be unified.
