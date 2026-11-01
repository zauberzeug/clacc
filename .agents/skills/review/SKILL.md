---
name: review
description: 'Review changes (a branch, uncommitted work or named files) against REVIEW.md and report findings as BLOCKER, MAJOR and CLEANUP. Use for "review", "look over this", "review the branch", "code review", "schau drüber", or before committing or opening a pull request. Reports only and applies no fixes.'
argument-hint: '[file, branch, or nothing for uncommitted changes]'
---

Read `REVIEW.md`, `REQUIREMENTS.md` and `CONTRIBUTING.md` first, and the requirements the change touches.

Review what the caller names by the criteria, severity marks and tone of `REVIEW.md`:

- With nothing named, review the uncommitted changes.
- With a branch, review it against `main`.
- With named files, review those files.

On `main` nobody else may look at this work before it reaches users, so your review may be the only one it gets.
Say where you are unsure rather than staying silent, and report only: applying fixes is a separate step.
