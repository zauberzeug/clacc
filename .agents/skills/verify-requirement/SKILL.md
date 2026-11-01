---
name: verify-requirement
description: 'Check that the named requirements are implemented and that their checks and the whole suite pass, and on success flip status from planned to active. Use for "verify", "is it done", "flip to active", "ist das fertig", or right after an implementation landed. Runs after implementation; writing the requirement is define-requirement.'
argument-hint: '[R-009 R-030]'
---

Read `REQUIREMENTS.md` first.

Verify the named requirements, or if none are named, the ones the current work touches.

1. Read the requirement and derive what must be observable.
   If you do not understand it at first reading, simplify it without changing the rule, because what cannot be read in one way cannot be verified.
2. Find the sections in `tests/*.sh` whose heading names this ID, and read their checks.
   A requirement of the type `behavior`, `cli` or `data-format` without a section needs one, so ask for it or write it.
3. Run the full gate, `make check`, with its output in a file, and read the exit code.
   The checks of the other requirements are the net against regressions, so a failure anywhere means an older requirement broke.
4. Search `requirements/` for statements this change may have made false, and report them.
5. On success, set `status: planned` to `active`.
   On failure, report what is missing and leave the status alone.

Say what the tests cannot show: they run on stand-ins, so a change to how clacc works with Claude Code also needs one real run by a person (R-024).
