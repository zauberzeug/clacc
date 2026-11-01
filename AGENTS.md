# AGENTS.md

Instructions for every coding agent in this repository.
Claude Code reads this file too, but only as long as there is no `CLAUDE.md`, so do not add one, for example through `/init`.

clacc is one bash script that switches Claude Code between accounts.
[README.md](README.md) explains it to users, and [`requirements/`](requirements/) says what it must do and why.
[CONTRIBUTING.md](CONTRIBUTING.md) is the process for people and agents alike, so read it, and the requirement of whatever you change, before you change it.

## Language

Everything in this repository is English, so that anyone can take part: code, comments, documentation, requirements, commit messages, pull requests, issues and review comments.
This holds whatever language a request comes in, and it overrides personal instructions about the language of such texts.
Answer the person in the language they wrote in.

## Real logins

**Do not run `clacc switch`, `add`, `save`, `rename` or `run` outside the tests.**
They act on the user's real logins, and a `switch` moves every running session, this one included.
The tests need none of that, because they run on stand-ins in a throwaway home folder (R-026).

## Mainline development

`main` is the one long-lived branch, and work lands on it directly.

**Commit every green, self-contained step and push it without asking.**
This is a standing authorization from the maintainers for this repository, and it overrides any default of your tool to wait for a request before committing or pushing.
It covers commits and pushes of the work you were asked to do, and nothing else.

Open a pull request instead when someone asks for one, when you have no write access, or when a change needs a discussion before it lands.

A push is a release, because `install.sh` downloads `clacc` from `main` (R-025).
The push gate holds back what fails (R-028), so run `make setup` once per clone.

### What makes a commit good enough to push

- **Requirement first.** New or changed behavior starts in `requirements/`, in the same commit or an earlier one.
  Change a requirement only for behavior you were asked to change.
  What you think should change becomes an issue.
- **Failing check first.** Write the check, see it fail for the right reason, then write the code, and commit both together.
- **Boy scout rule.** Mechanical cleanup goes into a commit of its own, and whatever would change behavior without a decision becomes an issue.
- **A new safeguard gets a check and a mutant** (R-027).
- **Scope bounds the diff, not your reading.** Read what surrounds a change, and assume bugs exist there: a green test is evidence, not proof.
- **README and `clacc --help` stay in step** with what a person can see.
- **The commit message records what the diff cannot:** why the change was needed, what you deliberately left out, the decisions you made where a requirement left a gap, and what you ran.

## Commands

```sh
make setup   # once per clone: turns on the push gate
make check   # everything the gate runs: lint, tests and mutants
make lint    # shellcheck and the requirements check

mkdir -p tmp
tests/run.sh > tmp/run.out 2>&1; echo "exit=$?"; grep -E '^(FAIL|--- )' tmp/run.out
```

A single check cannot run alone, because the sections of `tests/run.sh` build on one another.
[REQUIREMENTS.md](REQUIREMENTS.md#linking-checks) shows how to read the checks of one requirement.
`CLACC=<path> tests/run.sh` tests another copy of the script.

**Never end a gate in a filter.**
`make check | tail` reports the exit code of `tail`, so write the output to a file and read the exit code.

**`make check` and `git push` take minutes,** and far longer while other sessions run theirs, which can exceed the default timeout of your tool.
Give them a long timeout or run them in the background with their output in a file.
A push stopped during its gate is harmless, because nothing has been sent yet.

**After a push, watch CI,** a few seconds later:

```sh
gh run watch --exit-status "$(gh run list --commit "$(git rev-parse HEAD)" --json databaseId -q '.[0].databaseId')"
```

A red `main` is your next job, and a new commit or `git revert` fixes it, never a rewrite of history.
Reading the log of a run takes admin rights, but a run names a mutant the tests missed in a public annotation.

## Parallel sessions

Several agents can work in this repository at once, on one machine.

- **Work in a worktree of your own,** under `.claude/worktrees/`, unless you know you are alone, and push it with `git push origin HEAD:main`.
  The tests read the tree, and bash reads a script while it runs, so another session's edit can change what you are testing.
- **Run `git status --short` first.** A diff you do not recognize belongs to someone else, so leave it alone.
- **Commit explicit paths:** `git commit -m "..." -- <paths>`, after `git add <paths>` for new files.
  The message goes before the paths, and a bare `git commit` takes whatever the shared index holds.
- **Never use** `git add -A`, `git add .`, `git reset --hard`, `git clean -f`, `git stash`, `--amend`, a force-push, a rebase or `--no-verify`.
- **When the push is refused because `main` moved,** run `git fetch` and `git merge origin/main` (a merge, never a rebase), resolve by meaning, and run the gate again.
  A rename on one side and an edit on the other is the treacherous case, so read the merged file.
- **Other sessions' test runs are not yours to stop,** however much they slow yours down.

## Where a finding goes

A finding has three places, and no fourth:

1. **Fix it now,** when it is small and you are in that code anyway.
2. **A GitHub issue,** when it is larger or needs a decision.
   Open issues are the only backlog, so keep no TODO file, plan file or card deck in or beside the repository.
   An issue is public, so propose it to the person you work for and post it once they agree.
3. **A `NOTE:` comment,** when there is nothing to do but the next reader would trip over it.

## Reading the code

Reference code by symbol, not by line number, and repair a broken reference when you meet one.

- **A token's place is named by a path.**
  `has_token`, `read_token`, `move_token` and `remove_command` take a file path, which means that file on Linux and, on macOS, the Keychain item that `keychain_service` derives from it.
  All token access goes through them, apart from the Linux branch of `swap_tokens`.
- **`die` is safe anywhere,** because the EXIT trap `cleanup` brings back a lent token and releases the locks.
  Checks still come before the first write (R-010).
- **JSON goes through `jq_to`,** so a reader never sees half a file.
- **`$global` is the folder of the caller,** and it is empty for the default one (R-020).
  `$claude_dir`, `$config` and `$token` follow from it.
- **`keychain_service` hashes the path as written, while `lock_all` resolves it,** and these two must not be unified (R-021).

In the tests, `tests/stub/` holds the stand-ins, which log their calls to `$HOME/stub.log`, `$HOME/security.log` and `$HOME/sleep.log`.
A line `password has been deleted.` in the output comes from the stand-in for `security`.

## Skills

The skills live in `.agents/skills/`, and `.claude/skills/` links to them.

| Skill                | Use it to                                                         |
| -------------------- | ----------------------------------------------------------------- |
| `analyze`            | explain a bug or strange behavior, without changing anything      |
| `define-requirement` | turn a wished change into a requirement, before any code          |
| `add-feature`        | take a feature from idea to pushed commit                         |
| `verify-requirement` | check that a requirement is met, and flip `planned` to `active`   |
| `review`             | review a diff against [REVIEW.md](REVIEW.md), reporting only      |
| `commit`             | commit a green step and push it                                   |
| `collaboration`      | write pull request texts and comments on GitHub                   |

## Before you finish

- `make check` is green on what you pushed, and so is CI on both systems.
- Behavior that changed has its requirement, its check and, for a safeguard, its mutant.
- You have said plainly what is unfinished, what you could not verify, and what only a real login can show (R-024).
