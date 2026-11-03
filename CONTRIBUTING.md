# Contributing to clacc

Thank you for your interest in clacc!
This file is the process for people and coding agents alike, and agents also read [AGENTS.md](AGENTS.md).

Everything in this repository is in English, so that anyone can take part: code, documentation, commit messages, issues and pull requests.

## Reporting a problem

Open [issues](https://github.com/zauberzeug/clacc/issues) are the only backlog, so please search them first.
A good report says what you ran, what happened and what you expected, along with your operating system and the output of `claude --version`.

**Never paste a token, a `.credentials.json` or a `.claude.json`,** because they hold your login.

## Setting up

You need bash, `jq`, `make`, `git` and [`shellcheck`](https://www.shellcheck.net).

```sh
make setup   # once per clone: turns on the push gate
make check   # everything the gate runs: lint, tests and mutants
```

The tests run on stand-ins in a throwaway home folder, so they never touch your logins (R-026).
Trying a change on your real accounts is a different matter: `clacc switch` moves every running session on the machine.

## Making a change

### Requirements first

New or changed behavior starts with its requirement in [`requirements/`](requirements/), in the format of [REQUIREMENTS.md](REQUIREMENTS.md).
A new requirement starts as `planned` and becomes `active` once it is implemented and verified.
A bug fix needs no new requirement when an existing one already says what should happen.

### Tests first

1. Write the check that fails without your change, and see it fail for the right reason.
2. Write the code until it passes.
3. Commit the check and the code together, so that every commit passes.

A check tests what a person can observe through the command line and on disk, not how clacc does it.
Copy the shape of a recent check in [`tests/run.sh`](tests/run.sh): `setup`, `run <command>`, then `check "what must hold" '<condition>'`.
The heading of each section names the requirements it covers.

A check must not depend on how fast the machine runs, so it counts waits instead of timing them (R-026).

A new safeguard also gets a mutant in [`tests/mutants.sh`](tests/mutants.sh): a `sed` program that removes it, and that the tests must catch (R-027).
A mutant fails when its edit no longer applies, so a rewrite of the line it edits means updating the mutant too.

### The boy scout rule

Leave the code a little better than you found it.
Whatever you notice on the way that is small and safe, fix it, in a commit of its own, so that the diff of your change stays readable.
Whatever would change behavior without a decision becomes an issue instead.

Delete dead code rather than keeping it around.
The one exception is a store from an earlier version of clacc, which must keep working (R-003).

### Keeping it simple

Each commit is a complete, working step.
Prefer the simplest code that meets the requirement, and three similar lines to an abstraction nobody asked for.
clacc stays one script with no dependencies beyond `jq` and the base tools, and `curl` to install or update it (R-023).

## Landing a change

There are two ways.

**Pull request.** This is the way for everyone without write access, and for anything that needs a discussion first.
Fork the repository or make a branch from `main`, fill in the template, and get CI green.
A maintainer squash-merges it, so the title becomes the commit subject on `main`.
To catch up with `main`, merge it into your branch, and do not force-push.

**Mainline.** Maintainers and their agents commit straight to `main` in small green steps and push as they go.
A push is a release, because `install.sh` and `clacc update` download `clacc` from `main` (R-025, R-033).
So `make setup` turns on a gate that checks each push to `main` on a clean copy (R-028), and CI runs every push on Linux and macOS.
A red `main` is the next job, and a new commit or `git revert` fixes it, never a rewrite of history.

## Commit messages

The subject is an imperative with the verb first, and says what the change does: "Stop the tests before they can delete the folder they start in".
A label such as "macOS support" is no subject.

The body says what the diff cannot: why the change was needed, what was deliberately left out, the decisions made where a requirement left a gap, and what was run.

## Shell conventions

clacc runs on the bash 3.2 of macOS, and with both BSD and GNU tools (R-023).

- There are no associative arrays, no `mapfile` and no `${var,,}`.
  An empty array under `set -u` needs `${a[@]+"${a[@]}"}`.
- There is no `realpath -m` and no `mv -T`.
  Use `cd -P ... && pwd -P` to resolve a path.
- `stat` goes through `file_mode` and `file_time`, with GNU first, because BSD `stat` refuses `-c` while GNU `stat` reads `-f` as something else.
- clacc runs under `set -e`, so a guard is `[[ cond ]] || die "..."`, and a conditional action is `if cond; then action; fi`, never `cond && action`.
- The tests run under a German or any other locale too, so what parses a decimal number sets `LC_ALL=C`.
- CI has an older `shellcheck` than most machines, and it reports the same finding under another code, which is why the tests disable both SC2317 and SC2329.

## Documentation

Each rule has one home.

| Place                    | Holds                                            |
| ------------------------ | ------------------------------------------------ |
| `requirements/`          | what clacc must do, and why                      |
| the code and its comments | how it does it                                   |
| `README.md`              | what a user needs                                |
| `CONTRIBUTING.md`        | how a change gets made                           |
| `AGENTS.md`              | what only an agent needs                         |
| `REVIEW.md`              | what a review looks for                          |

A sentence that would survive a rewrite of the code belongs in a requirement, and one that would not belongs in the code.
In new Markdown files every sentence starts on a new line, which keeps diffs small.

## AI-assisted contributions

Contributions written with a coding agent are welcome.
Point your agent at [AGENTS.md](AGENTS.md), and read what it wrote before you submit it: you are responsible for the result.
