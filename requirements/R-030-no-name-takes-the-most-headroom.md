---
type: behavior
tags: [headroom, switch, run]
status: active
---

# Without a name, the most headroom decides

`clacc switch` and `clacc run` without a name take the stored account with the most headroom.
What clacc compares goes to stderr, because in a `run` stdout belongs to claude.

clacc reads the `/usage` text of each account and takes what is left of the tighter of two limits, `Current session` and `Current week (all models)`:

- For example, an account with 20% of its five hours and 30% of its week used has 70% left.
- One limit alone is enough, and a limit on a single model does not count.
- A limit past its end counts as nothing left.
- A tie stays on the active account, so a tie moves nobody.

clacc names what it leaves out of the comparison:

- an account without a token, with the command `clacc add <name>`,
- an account whose usage cannot be read,
- an active login that is not stored, with the command `clacc save <name>`.

With no account readable, or none with anything left, clacc exits with 1 and asks for a name: `clacc <command> <name>`.

A reading goes through the login of the run folder when an account has one, and otherwise through the active login or a parked token (R-031).
`switch` needs the active login or a parked token, while `run` also takes an account that has only the login of its run folder.

A reading sends no prompt and saves no session, and it runs from the store, away from any project.
