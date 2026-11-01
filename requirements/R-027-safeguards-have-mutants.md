---
type: decision
tags: [tests]
status: active
---

# Safeguards have mutants

A safeguard in clacc, in `install.sh` or in the checks of this repository gets a mutant in `tests/mutants.sh`: a `sed` program that removes or weakens it.
The tests must catch every mutant, and each mutant must still apply to the text it edits, so a rewrite cannot quietly disarm it.

A green test shows that a check passes, not that it would ever fail.
A mutant shows that the check fails when it should.
