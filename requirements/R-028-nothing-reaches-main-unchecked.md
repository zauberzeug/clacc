---
type: behavior
tags: [workflow, tests]
status: planned
---

# Nothing reaches main unchecked

A push to `main` runs the full gate first, and a red gate refuses the push, because `main` is what `install.sh` hands to users (R-025).

- The gate runs on a clean copy of the pushed commit, so an uncommitted file cannot decide the result.
- A push that changes only Markdown runs the lint alone, which includes the requirements check (R-029).
- A push to another branch runs no gate.
- Every push and pull request also runs in CI, on Linux and macOS.

`make setup` turns the gate on in a clone, through `core.hooksPath`.
