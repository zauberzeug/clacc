---
type: decision
tags: [design]
status: active
---

# clacc relies on Claude Code's internals

clacc builds on how Claude Code stores and reloads its login, which is not a documented interface and can change with any update:

- where a login and a record live, and the names of the Keychain items,
- that a session reloads a changed token file and rereads its Keychain item every 30 seconds,
- the lock folders Claude Code takes,
- the wording of the `/usage` text (R-030).

The README names the versions clacc was written against.
The stand-ins in `tests/stub/` record what was observed then, so green tests say nothing about a newer Claude Code.
After an update of Claude Code, a person runs the tests and one real switch, because only a person can act on real logins (R-026).
