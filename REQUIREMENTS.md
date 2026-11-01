# Requirements of clacc

All requirements live in [`requirements/`](requirements/), one Markdown file per requirement.
A requirement is anything that should hold for clacc: a concept, a behavior, a command line, a data format, a user story or a design decision.
A change in behavior starts with its requirement ([CONTRIBUTING.md](CONTRIBUTING.md#requirements-first)).

## Files and IDs

A file name is an ID plus a short slug: `R-009-switch-moves-every-session.md`.

- IDs run without a gap and are never reused.
  A new requirement takes the highest number plus one.
- The ID appears in the file name only, not inside the file.
- A requirement that is given up keeps its file with `status: retired`, because tests, commits and discussions can still point to its ID.
- There is one file per rule a test could check.
  Concepts and decisions often have no test, and that is fine.
- When a requirement changes, edit its file: the ID names the requirement, not one wording of it, and git keeps the history.
  As a rule of thumb, it is still the same requirement if its checks survive the change, perhaps adapted.
  If something fundamentally different takes its place, retire the old file with a note such as "Replaced by R-009" and give the new one a new ID.
- A new requirement starts with `status: planned` and becomes `active` once it is implemented and verified.

## File format

```markdown
---
type: behavior
tags: [switch, tokens]
status: active
---

# A switch moves every session

The rule first, then the reason when the "why" is not obvious.
```

| Field    | Values                                                           |
| -------- | ---------------------------------------------------------------- |
| `type`   | `concept` `user-story` `decision` `behavior` `cli` `data-format` |
| `tags`   | a free list for searching, such as `[switch, macos]`             |
| `status` | `active` `planned` `retired`                                     |

The types mean:

- `concept`: the words clacc uses and what they name.
- `user-story`: what a person wants, and why.
- `decision`: a design decision and its reason, which a test can rarely check.
- `behavior`: what clacc does to logins, files, locks and sessions.
- `cli`: what a person types and reads: commands, output and exit codes.
- `data-format`: what clacc keeps on disk.

A requirement has no priority, because open issues are the only backlog.

A requirement states the general rule.
It names no individuals.

## Write it to be understood at first reading

Someone who does not know the code should understand a requirement at first reading.

- **The rule first.**
  The first sentence says what holds, and the reason follows.
- **One thought per sentence, with the subject up front.**
  "clacc takes the lock" rather than "Taken by clacc is the lock".
  One subordinate clause is fine, and two nested ones are one too many.
- **Verbs rather than nouns, active rather than passive.**
  "clacc checks the record", not "Verification of the record is performed".
- **Say what holds.**
  Say what is true rather than what is not ruled out.
  What clacc does not do belongs in a commit message or a pull request.
- **An example right after the rule.**
  A concrete case explains an exception better than an abstract clause.
- **Lists instead of nested clauses.**
  Several cases go into a list, and a sequence into a numbered list.
- **One word for one thing,** namely the word of R-002: always "login", never "login" here and "credential" there.
- **Explain jargon or avoid it.**
  What only a reader of the code knows gets half a sentence of explanation at its first mention.
- **Cross-references sparingly, at the end of a sentence.**
  A link in the middle of a statement interrupts it.
- **What holds, not how it came about.**
  What clacc used to do stays out, also in a reason, because git knows the history.
- **One sentence per line.**
  A long sentence breaks at a natural boundary, such as after a subordinate clause.

Before:

> A running session, which watches the modification time that clacc renews right before the `mv` that replaces the active file (R-009), reloads its login when that time has changed.

After:

> A running session reloads its login when the modification time of the file changes.
> clacc renews that time before it puts a login in place (R-009).

Read the text as if you did not know the code, preferably aloud.
Where you have to catch your breath or jump back, split the sentence, and where you miss an example, add one.

### Keep the meaning when rewriting

Whoever rewrites a sentence reads it twice afterwards: once without the code, to see whether it is understood, and once with the code, to see whether it still holds.
`git show main:requirements/<file>` shows the old wording for comparison.
The meaning nearly always shifts in one of four places:

- **A word like "it", "they" or "here" points elsewhere.**
  After a sentence is split, such a word can point to something else than before, so read the next sentence too.
- **Examples turn into a closed list.**
  "Calls that start no session, such as `--version`" covers more than "The call `--version`".
- **An example turns into the rule** once it moves into the subject.
  "An account that cannot be read, for example one without a login" is not the same as "An account without a login cannot be read".
- **A precision claims something new.**
  A new "only", "never", "all" or definition is a statement about the code.
  Check it there, preferably by running the code.

## Linking checks

The heading of a section in `tests/run.sh` or `tests/gates.sh` names the requirements its checks cover:

```bash
echo "--- switch back (R-005, R-009)"
```

A section can name several requirements, and several sections can name one requirement.
To read the checks of one requirement, filter the output of a run:

```sh
tests/run.sh > tmp/run.out 2>&1; awk '/^--- /{show=/R-009/} show' tmp/run.out
```

## The check

`tests/requirements.sh` runs with `make lint`, and R-029 lists what it checks.
Examples in this repository use IDs that exist, because the check reads every mention, this file included.
