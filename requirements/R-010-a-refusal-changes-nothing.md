---
type: behavior
tags: [switch, safety]
status: active
---

# A refusal changes nothing

When clacc refuses a command, every login and record stays as it was and no lock stays behind.
clacc checks before its first write, and it releases its locks on every exit.

A switch refuses:

- an unknown account, or a name that cannot be one (R-004),
- a machine with no active login,
- an active login that is not stored, and asks to name it first: `clacc save <name>`,
- an account without a token, and points to `clacc add <name>`,
- a parked token that cannot be read.

On macOS a locked Keychain or a write the Keychain drops stops a switch in the same way, and no login is lost (R-022).
