# clacc

Switch [Claude Code](https://code.claude.com) between your accounts: every running session at
once, or one new session on its own.

[![test](https://github.com/zauberzeug/clacc/actions/workflows/test.yml/badge.svg)](https://github.com/zauberzeug/clacc/actions/workflows/test.yml)

```console
$ clacc
active: personal (me@example.com)
stored: work (me@company.com)

$ clacc work
switched from personal to work (me@company.com); running sessions follow at their next request

$ clacc run personal
```

`clacc work` moves every Claude Code session on the machine to the work account, the running
ones included, with no restart and no new login. `clacc run personal` starts one more session on
the personal account, and all the others stay where they are.

## Why

Claude Code keeps one login per machine. Signing in with `/login` replaces it, so going from a
personal subscription to a company one, for example when one has reached its usage limit, means
a new browser login every time and a restart of every open session. clacc keeps each account you
have signed in to once, and swaps them in place.

## Install

clacc is a single bash script. It needs Linux, [jq](https://jqlang.org) and Claude Code.

```sh
curl -fsSL https://raw.githubusercontent.com/zauberzeug/clacc/main/clacc -o ~/.local/bin/clacc
chmod +x ~/.local/bin/clacc
```

Or clone this repository and link `clacc` into a folder on your `PATH`.

## Usage

```sh
clacc save personal      # name the login you have now
clacc add work           # sign in to another account in the browser; nothing else changes
clacc work               # move every session to work
clacc personal           # and back
clacc run work           # one new session on work's own login; its first start signs in
clacc run work -c        # arguments after the name go to claude
clacc rename work acme   # give a stored account another name
clacc                    # show the active account, the stored ones and the local ones
```

A shortcut for sessions on one account is a one-line alias:

```sh
alias wclaude='clacc run work'
```

## How it works

**Every session at once.** Claude Code keeps its login in `~/.claude/.credentials.json`, and a
running session reloads that file when its modification time changes. The account's email and
organisation sit in `~/.claude.json`. clacc takes the lock folders that Claude Code itself takes
around refreshing a token, writing a token and writing its config. It moves the active token into
`~/.clacc`, renames the other account's token into its place and swaps the account record. Running
sessions pick up the new token at their next request.

**One session on its own.** `clacc run <name>` starts Claude Code with `CLAUDE_CONFIG_DIR` set to
`~/.clacc/<name>.local`. That folder holds a login and a `.claude.json` of its own. For settings,
skills, plugins, projects with their memory, and history, it links to `~/.claude`, so the session
works like any other. It cannot share `~/.claude.json`, because Claude Code regularly writes the
account of the token it runs on into that file, and every other session would then show that
account. So a `run` session has a second, independent login of the account, made at its first
start, and each start checks that this login belongs to the account and organisation stored under
that name.

**Care with tokens.** When Claude Code refreshes a token, the server can hand out a new refresh
token and retire the old one, so a copy of a login can stop working at the next refresh. clacc
never copies a login: each one lives in exactly one file, readable by you only.

## Good to know

- clacc relies on how Claude Code stores and reloads its login. That is not a documented
  interface, and an update can change it. clacc was written against Claude Code 2.1.316. After an
  update, run the tests and one switch.
- Linux only for now. On macOS, Claude Code keeps the login in the Keychain.
- Prompt cache, artifacts and remote sessions belong to an account. After a switch, a session's
  first request cannot reuse the previous account's cache, and pages published from the other
  account are out of sight.
- clacc follows `CLAUDE_CONFIG_DIR` when you have set it for Claude Code. It keeps its own files in
  `~/.clacc`, or in the folder named by `CLACC_HOME`.

## Tests

`tests/run.sh` runs clacc against a stand-in for `claude` in a throwaway home folder.
`tests/mutants.sh` breaks each safeguard in turn and checks that the tests notice.

## License

[MIT](LICENSE). clacc is not affiliated with Anthropic.
