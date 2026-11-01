---
type: behavior
tags: [accounts]
status: active
---

# Save names the active login

`clacc save <name>` stores the record of the active login under `<name>`.
The token stays where it is, and the next switch away parks it under that name.
For example, after a plain `/login` to an account clacc does not know yet, `clacc save work` makes it a stored account.

clacc refuses and stores nothing when:

- there is no active login,
- the active login is already stored under another name,
- `<name>` belongs to another account.
