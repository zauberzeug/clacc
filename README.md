# clacc

Switch [Claude Code](https://code.claude.com) between your accounts: every running session at
once, or one new session on its own.

[![test](https://github.com/zauberzeug/clacc/actions/workflows/test.yml/badge.svg)](https://github.com/zauberzeug/clacc/actions/workflows/test.yml)

```console
$ clacc
active: personal (me@example.com)
stored: work (me@company.com)

$ clacc switch work
switched from personal to work (me@company.com); running sessions follow at their next request

$ clacc run personal

$ clacc switch
personal: 23% left (five hours 77% used, week 40% used)
work: 88% left (five hours 12% used, week 9% used)
most headroom: work
already on work (me@company.com)
```

`clacc switch work` moves every Claude Code session on the machine to the work account, the
running ones included, with no restart and no new login. `clacc run personal` starts one more
session on the personal account, and all the others stay where they are. Leave the name out and
clacc takes the account with the most headroom. A name alone, without a command, switches nothing,
so a slip of the keyboard cannot move every session.

## Why

Claude Code keeps one login per machine. Signing in with `/login` replaces it, so going from a
personal subscription to a company one, for example when one has reached its usage limit, means
a new browser login every time and a restart of every open session. clacc keeps each account you
have signed in to once, and swaps them in place.

## Install

clacc is a single bash script. It needs Linux or macOS, [jq](https://jqlang.org) and Claude Code.

```sh
curl -fsSL https://raw.githubusercontent.com/zauberzeug/clacc/main/install.sh | bash
```

This puts `clacc` into `~/.local/bin`. Later, `clacc update` or this line again gets the newest
version.

Or clone this repository, link `clacc` into a folder on your `PATH`, and update it with `git pull`.

## Usage

```sh
clacc save personal      # name the login you have now
clacc add work           # sign in to another account in the browser; nothing else changes
clacc switch work        # move every session to work
clacc switch personal    # and back
clacc switch             # move every session to the account with the most headroom
clacc run work           # one new session on work's own login; its first start signs in
clacc run work -c        # everything after the name goes to claude, a leading -- dropped
clacc run                # one new session on the account with the most headroom
clacc run -c             # the same, with options for claude
clacc run -- "fix it"    # and with a prompt, which would otherwise be read as a name
clacc rename work acme   # give a stored account another name
clacc                    # show the active account, the stored ones and the local ones
clacc update             # get the newest clacc from the main branch
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

**On macOS.** Claude Code keeps each login in the Keychain instead of a file, and clacc keeps the
tokens it stores there too. A running session rereads its Keychain item every 30 seconds, so a
request within that time still runs on the previous account. A login item also holds the sign-ins
to MCP servers, so those switch with the account.

**One session on its own.** `clacc run <name>` starts Claude Code with `CLAUDE_CONFIG_DIR` set to
`~/.clacc/<name>.local`. That folder holds a login and a `.claude.json` of its own, and links to
`~/.claude` for skills, plugins, projects with their memory, and history, so the session works like
any other. It cannot share `~/.claude.json`, because Claude Code regularly writes the account of the
token it runs on into that file, and every other session would then show that account. So a `run`
session has a second, independent login of the account, made at its first start, and each start
checks that this login belongs to the account and organisation stored under that name. Calls that
start no session, such as `--version` or `mcp list`, need no login and go straight to claude.

The folder's `settings.json` is a copy of yours, renewed at every start, except for the model.
Accounts offer different models, so a model picked with `/model` in a `run` session stays that
account's default. Any other setting such a session changes goes back to your own settings at the
next start.

**The most headroom.** Without a name, clacc runs `claude -p /usage` with each stored account's
login and takes the account with the most left on the tighter of its five-hour and weekly limits.
That command is local: it sends no prompt and uses none of your limits, and it takes a few seconds
per account. Limits on a single model do not count, a tie stays on the active account, and an
account it cannot read is named and left out. With nothing left on any account, clacc says so and
moves nothing. A `switch` compares the accounts it can switch to, and a `run` also those with nothing
but the login of their own folder.

**Care with tokens.** When Claude Code refreshes a token, the server can hand out a new refresh
token and retire the old one, so a copy of a login can stop working at the next refresh. clacc
never keeps a copy of a login: each one lives in exactly one file readable by you only, or on macOS
in one Keychain item. The Keychain has no atomic rename, so there clacc removes the old item only
once the new one reads back correctly. A token too long for the standard input of `security`, as a
login with MCP sign-ins often is, goes on its command line, where other processes on the machine
can read it for a moment. To read a parked account, clacc lends its token to a temporary config
folder, where Claude Code renews it if it has expired, and takes it back afterwards, however the
reading ends. A switch waits meanwhile.

## Good to know

- clacc relies on how Claude Code stores and reloads its login, and on the wording of `/usage`.
  Neither is a documented interface, and an update can change them. clacc was written against
  Claude Code 2.1.316, and its macOS part against 2.1.303. After an update, run the tests and one
  switch. Should the wording change, clacc says it cannot read the usage, and you name the account
  yourself.
- Picking an account by headroom has run on real accounts only on Linux so far, with 2.1.316.
- Headroom is a percentage of each account's own limits, because that is all `/usage` shows. 20% of
  a large plan can be more usage than 30% of a small one, and clacc does not weigh that.
- One email in two organisations, such as a personal subscription and a company plan, is two
  accounts to clacc, each with a name of its own, because it tells accounts apart by account and
  organisation, as Claude Code does.
- Prompt cache, artifacts and remote sessions belong to an account. After a switch, a session's
  first request cannot reuse the previous account's cache, and pages published from the other
  account are out of sight.
- clacc follows `CLAUDE_CONFIG_DIR` when you have set it for Claude Code. It keeps its own files in
  `~/.clacc`, or in the folder named by `CLACC_HOME`.

## Tests

`tests/run.sh` runs clacc against stand-ins for `claude` and the Keychain in a throwaway home folder,
on either system.
`tests/mutants.sh` breaks each safeguard in turn and checks that the tests notice.

## Contributing

Issues and pull requests are welcome.
[CONTRIBUTING.md](CONTRIBUTING.md) describes how a change is made, and [`requirements/`](requirements/) what clacc must do and why.

## License

[MIT](LICENSE). clacc is not affiliated with Anthropic.
