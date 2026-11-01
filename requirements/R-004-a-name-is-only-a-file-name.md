---
type: behavior
tags: [accounts, store]
status: active
---

# A name is only a file name

A name labels a stored account and says nothing about it.
clacc finds the active account by its account id, so a rename or a new name never changes which account is active.

A name consists of lowercase letters, digits, dots, `-` and `_`, and begins with a letter or a digit.
So it stays inside the store and shows up in a listing.
For example, `acme.de` and `mail.acme.de` are names, while `.hidden`, `..` and `a/../y` are refused.

A command word is a name like any other, because a name always follows a command: `clacc switch run` switches to the account named `run`.
