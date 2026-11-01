---
type: behavior
tags: [accounts]
status: active
---

# Add signs in on the side

`clacc add <name>` signs in to an account in the browser and stores it, while every session keeps its account.
The sign-in runs in a temporary config folder, so clacc writes neither the active login nor `.claude.json`.
The new login moves to the store as a parked token, and the temporary folder goes, however `add` ends.

clacc refuses and stores nothing when:

- `<name>` already has a token or is the name of the active login,
- the sign-in was to an account already stored under another name,
- the sign-in was to another account than the record under `<name>`,
- no login happened.
