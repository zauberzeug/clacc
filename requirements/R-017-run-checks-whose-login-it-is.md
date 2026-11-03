---
type: behavior
tags: [run, safety]
status: active
---

# Run checks whose login it is

Every start checks that the login of the run folder belongs to the account and organisation stored under that name.
A login of another account would run every later `run` session on it, so clacc then starts no session, exits with 1 and names the command that removes that login.

The check lets these pass:

- a login or a stored record with no organisation yet, as long as the account id is the right one,
- any login under a name with no stored account,
- a call of an `auth` subcommand such as `auth status`.
