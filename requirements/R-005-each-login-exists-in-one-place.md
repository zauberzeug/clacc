---
type: behavior
tags: [tokens]
status: active
---

# Each login exists in one place

Every login lives in exactly one place: one file readable by the user only, or on macOS one Keychain item.
clacc moves logins and never copies them or backs them up.

When Claude Code refreshes a token, the server can hand out a new refresh token and retire the old one.
A copy of a login can therefore stop working at the next refresh.

A run folder follows the same rule: it has a second login from a sign-in of its own, not a copy (R-015).
A login that Claude Code renews while it is lent out comes back in place of the old one (R-031).
