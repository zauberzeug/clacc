---
type: cli
tags: [status]
status: active
---

# Status shows every account

`clacc` and `clacc status` print one line per account and leave every login and record alone:

```console
active: personal (me@example.com)
stored: work (me@company.com)
stored: old (me@old.example), no token: clacc add old
local:  work (me@company.com), for single sessions: clacc run work
```

- `active:` is the account of the active login, or `not stored` when clacc has no name for it.
- `stored:` is every other stored account, and says so when it has no token.
- `local:` is every run folder with the account of its login, or `no login yet`.
