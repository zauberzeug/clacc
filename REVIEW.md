# Reviewing a change to clacc

A review looks for what the tests cannot see.
clacc handles people's logins, so a small mistake can lock someone out of an account or leave a token where it should not be.

**Question the approach first.**
Does the change need to exist, does it fit [R-023](requirements/R-023-a-single-portable-bash-script.md), and is there a simpler way?
Then read the details.

## Severity

Mark each finding, and name the file, the symbol and what goes wrong:

- **BLOCKER:** loses or exposes a login, breaks a command on one of the two systems, or breaks a requirement.
- **MAJOR:** a bug outside the main path, a safeguard without a check, or a change that will mislead the next reader.
- **CLEANUP:** naming, simplification, a stale comment.

Say where you are unsure instead of staying silent, and keep the tone friendly and direct.
Praise is welcome, and "looks good" with nothing to add is a fine result.

## What to look for

**Logins (R-005, R-021, R-022)**

- A token copied or backed up instead of moved, or left behind in a temporary folder.
- A token in a file on macOS, in a log or in any output.
- A token on a command line when it would fit through standard input.
- Token access outside `has_token`, `read_token`, `move_token` and `remove_command`.

**Names and paths (R-004)**

- A name that reaches a path without `check_name`.
- A missing quote, an `eval`, or anything else that lets a name or a path act as code.

**Refusals and locks (R-010, R-011)**

- A check after the first write, which breaks "a refusal changes nothing".
- A write to a login or a record without `lock_all`.
- A file written in place rather than through `jq_to` or a rename.

**Portability (R-023)**

- A feature bash 3.2 lacks, or a flag only BSD or only GNU tools know.
- `cond && action` under `set -e`, which ends the script when `cond` is false.
- A pipeline whose failure goes unnoticed, or a `$(...)` whose failure is hidden by a surrounding command.

**Claude Code's internals (R-024)**

- An assumption about Claude Code that nobody verified against a real version.
- A new dependency on its internals that the list in R-024 and the README do not name.

**The tests (R-026, R-027)**

- Behavior without a check, a safeguard without a mutant, or a mutant whose edit no longer does what its name says.
- A check that passes on a slow machine for the wrong reason, or one that depends on the clock or the locale.
- A check coupled to how clacc works rather than to what a person can observe.

**Documents**

- Behavior that changed without its requirement.
- A README or `clacc --help` out of step with what a person can see.
