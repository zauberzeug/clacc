---
type: behavior
tags: [switch, tokens]
status: active
---

# A switch moves every session

`clacc switch <name>` makes the login of `<name>` the active login for every session on Claude Code's folder, running sessions included, without a restart or a new login.
A `run` session stays on its own login (R-015).

Under the locks of R-011, clacc:

1. saves the current record under the name of the active account,
2. parks the active token under that name,
3. puts the token of `<name>` in place with a new modification time,
4. replaces the record in `.claude.json` and keeps everything else in that file.

A running session reloads its login when the modification time of the file changes, so on Linux it follows at its next request.
On macOS it rereads its Keychain item every 30 seconds, so a request within that time still runs on the previous account (R-021).
clacc says which of the two applies.

A switch to the account that is already active says `already on <name>` and exits with 0.
