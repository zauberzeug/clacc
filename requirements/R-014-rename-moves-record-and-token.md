---
type: behavior
tags: [accounts]
status: active
---

# Rename moves record and token

`clacc rename <old> <new>` gives a stored account another name and moves its record and its parked token with it.
The active account can be renamed too, because clacc finds it by its account id (R-004).

clacc refuses when `<old>` is not stored, or when `<new>` cannot be a name or is already taken by a record or a token.

A run folder keeps the name it was made under.
After a rename, `clacc run <new>` makes a new run folder with a sign-in of its own.
