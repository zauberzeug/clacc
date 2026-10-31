#!/usr/bin/env bash
# Exercise clacc against a stand-in for claude, in a throwaway HOME with fake tokens.
# Usage: tests/run.sh   (CLACC=<path> tests another copy of the script)
# Each check is single-quoted on purpose and check() evaluates it, so shellcheck cannot see that
# the variables and helpers it uses are used (SC2317 in shellcheck 0.9, SC2329 from 0.10 on).
# shellcheck disable=SC2016,SC2034,SC2317,SC2329
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
script=${CLACC:-$(cd "$here/.." && pwd)/clacc}
HOME=$(mktemp -d)
export HOME
trap 'rm -rf "$HOME"' EXIT
unset CLAUDE_CONFIG_DIR CLAUDE_SECURESTORAGE_CONFIG_DIR CLACC_HOME CLACC_CLAUDE_CONFIG_DIR
S=$HOME/.clacc
fails=0
checks=0

check() {
  checks=$((checks + 1))
  if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi
}

setup() {
  rm -rf "$HOME"
  mkdir -p "$HOME/.claude/projects/p/memory" "$HOME/.claude/skills/s" "$S"
  echo '{"claudeAiOauth":{"accessToken":"tokA","refreshToken":"refA"}}' > "$HOME/.claude/.credentials.json"
  chmod 600 "$HOME/.claude/.credentials.json"
  echo '{"numStartups":5,"hasCompletedOnboarding":true,"cachedGrowthBookFeatures":{"f":1},"groveConfigCache":{},"oauthAccount":{"accountUuid":"aaaaaaaa-0000-0000-0000-000000000000","emailAddress":"a@x"},"projects":{"p":{"hasTrustDialogAccepted":true,"hasUnseenTeamArtifacts":true}}}' > "$HOME/.claude.json"
  echo '{"model":"opus"}' > "$HOME/.claude/settings.json"
  chmod 644 "$HOME/.claude/settings.json"
  echo "memory note" > "$HOME/.claude/projects/p/memory/m.md"
  echo "skill" > "$HOME/.claude/skills/s/SKILL.md"
  echo "global instructions" > "$HOME/.claude/CLAUDE.md"
  echo '{"accountUuid":"aaaaaaaa-0000-0000-0000-000000000000","emailAddress":"a@x"}' > "$S/alpha.account.json"
  echo '{"accountUuid":"bbbbbbbb-0000-0000-0000-000000000000","emailAddress":"b@x","organizationUuid":"org-b","organizationName":"org-b"}' > "$S/beta.account.json"
  echo '{"claudeAiOauth":{"accessToken":"tokB","refreshToken":"refB"}}' > "$S/beta.credentials.json"
  touch -d '1 hour ago' "$HOME/.claude/.credentials.json"
}

tok() { jq -r .claudeAiOauth.accessToken "$1"; }
active_tok() { tok "$HOME/.claude/.credentials.json"; }
rec() { jq -r .oauthAccount.emailAddress "$HOME/.claude.json"; }
sum() { sha256sum "$1" | cut -d" " -f1; }
last_log() { tail -n 1 "$HOME/stub.log"; }
no_locks() { [[ ! -e $HOME/.claude/.oauth_refresh.lock && ! -e $(realpath -m "$HOME/.claude").lock && ! -e $HOME/.claude/.storage-write.lock && ! -e $HOME/.claude.json.lock ]]; }
run() { out=$(PATH=$here/stub:$PATH "$script" "$@" 2>&1); code=$?; }
# Run in a pseudo-terminal, as from a person's terminal.
run_tty() { out=$(PATH=$here/stub:$PATH script -qec "$(printf '%q ' "$script" "$@")" /dev/null 2>&1); code=$?; }

echo "--- status"
setup
run
check "status names the active account" '[[ $out == *"active: alpha (a@x)"* ]]'
check "status lists the parked one" '[[ $out == *"stored: beta (b@x)"* ]]'
run status
check "status is also a command" '[[ $code == 0 && $out == *"active: alpha (a@x)"* ]]'
run status extra
check "status takes no argument" '[[ $code == 2 ]]'
run beta
check "a name alone switches nothing and names the command that does" '[[ $code == 2 && $out == *"clacc switch beta"* && $(active_tok) == tokA && $(rec) == a@x ]]'
run switch
check "switch without a name: usage, nothing switched" '[[ $code == 2 && $(active_tok) == tokA ]]'
run --help
check "--help prints the commands and exits 0" '[[ $code == 0 && $out == *"clacc switch <name>"* && $out == *"clacc run <name> [args...]"*"passing args to claude"* ]]'
run --bogus
check "a wrong option prints the commands and exits 2" '[[ $code == 2 && $out == *"clacc add <name>"* ]]'
STUB_UNAME=Darwin run
check "anything but Linux is refused" '[[ $code == 1 && $out == *"needs Linux"* ]]'

echo "--- switch alpha -> beta"
run switch beta
check "exit 0" '[[ $code == 0 ]]'
check "active token is beta" '[[ $(active_tok) == tokB ]]'
check "alpha token parked" '[[ $(tok "$S/alpha.credentials.json") == tokA ]]'
check "beta no longer parked (one copy only)" '[[ ! -e $S/beta.credentials.json ]]'
check "account record is beta" '[[ $(rec) == b@x ]]'
check "rest of ~/.claude.json kept" '[[ $(jq -c "[.numStartups, .projects.p.hasTrustDialogAccepted]" "$HOME/.claude.json") == "[5,true]" ]]'
check "active token mode 600, single link" '[[ $(stat -c "%a %h" "$HOME/.claude/.credentials.json") == "600 1" ]]'
check "parked token mode 600, single link" '[[ $(stat -c "%a %h" "$S/alpha.credentials.json") == "600 1" ]]'
check ".claude.json mode 600" '[[ $(stat -c %a "$HOME/.claude.json") == 600 ]]'
check "active token has a fresh modification time" '(( $(date +%s) - $(stat -c %Y "$HOME/.claude/.credentials.json") < 5 ))'
check "no lock left behind" no_locks
check "no temp file left behind" '[[ -z $(find "$HOME" -name "*.tmp.*") ]]'

echo "--- switch to the active one"
run switch beta
check "says already on beta" '[[ $code == 0 && $out == *"already on beta"* && $(active_tok) == tokB ]]'

echo "--- switch back"
run switch alpha
check "active token is alpha again" '[[ $code == 0 && $(active_tok) == tokA && $(rec) == a@x ]]'
check "beta parked again" '[[ $(tok "$S/beta.credentials.json") == tokB && ! -e $S/alpha.credentials.json ]]'

echo "--- refusals change nothing"
run switch nosuch
check "unknown account refused" '[[ $code == 1 && $out == *"no stored account"* && $(active_tok) == tokA ]]'
run switch ../x
check "path outside the store refused" '[[ $code == 1 && $(active_tok) == tokA ]]'
echo 'not json' > "$S/beta.credentials.json"
run switch beta
check "unreadable token refused" '[[ $code == 1 && $out == *"unreadable"* && $(active_tok) == tokA && $(rec) == a@x ]]'
check "no lock left after a refusal" no_locks
rm "$S/beta.credentials.json"
run switch beta
check "missing token points to add" '[[ $code == 1 && $out == *"clacc add beta"* ]]'

echo "--- a lock held by a live process"
setup
mkdir "$(realpath -m "$HOME/.claude").lock"
start=$(date +%s)
run switch beta
check "waits, then gives up" '[[ $code == 1 && $out == *"held by another process"* ]] && (( $(date +%s) - start >= 9 ))'
check "nothing switched" '[[ $(active_tok) == tokA && $(rec) == a@x ]]'
check "the other process keeps its lock, ours are released" '[[ -d $(realpath -m "$HOME/.claude").lock && ! -e $HOME/.claude/.oauth_refresh.lock && ! -e $HOME/.claude.json.lock ]]'
rmdir "$(realpath -m "$HOME/.claude").lock"

echo "--- a token write in progress"
setup
mkdir "$HOME/.claude/.storage-write.lock"
run switch beta
check "waits for Claude Code's token-write lock, then gives up" '[[ $code == 1 && $out == *".storage-write.lock is held"* ]]'
check "nothing switched while a token was being written" '[[ $(active_tok) == tokA && $(rec) == a@x ]]'
rmdir "$HOME/.claude/.storage-write.lock"

echo "--- a stale lock (untouched for 2 minutes)"
setup
mkdir "$(realpath -m "$HOME/.claude").lock"
touch -d '2 minutes ago' "$(realpath -m "$HOME/.claude").lock"
run switch beta
check "stale lock cleared, switch done" '[[ $code == 0 && $(active_tok) == tokB ]] && no_locks'

echo "--- a manual /login to an unknown account"
setup
jq '.oauthAccount = {accountUuid: "cccccccc-0000-0000-0000-000000000000", emailAddress: "c@x"}' "$HOME/.claude.json" > "$HOME/x" && mv "$HOME/x" "$HOME/.claude.json"
run switch beta
check "switch refused, asks to save" '[[ $code == 1 && $out == *"not stored"* && $(active_tok) == tokA ]]'
run save alpha
check "save under a name of another account refused" '[[ $code == 1 ]]'
run save gamma
check "save gamma" '[[ $code == 0 && $(jq -r .emailAddress "$S/gamma.account.json") == c@x ]]'
run
check "status now says gamma" '[[ $out == *"active: gamma (c@x)"* && $out == *"stored: alpha (a@x), no token"* ]]'

echo "--- add a new account through a login of its own"
setup
before=$(sum "$HOME/.claude.json")
STUB_LOGIN=d run add delta
check "exit 0" '[[ $code == 0 ]]'
check "delta record and token stored" '[[ $(jq -r .emailAddress "$S/delta.account.json") == d@x && $(tok "$S/delta.credentials.json") == tokD ]]'
check "the login ran in a config folder of its own" '[[ $(last_log) == "auth config=$S/login."*" secure=unset global=unset args=auth login --claudeai" ]]'
check ".claude.json not written at all" '[[ $(sum "$HOME/.claude.json") == "$before" ]]'
check "active login untouched" '[[ $(active_tok) == tokA ]]'
check "login folder removed" '[[ -z $(find "$S" -name "login.*") ]]'
run switch delta
check "can switch to the added account" '[[ $code == 0 && $(active_tok) == tokD && $(rec) == d@x ]]'

echo "--- add refusals"
setup
before=$(sum "$HOME/.claude.json")
STUB_LOGIN=b run add beta
check "add of a name with a token refused" '[[ $code == 1 && $out == *"already stored"* ]]'
STUB_LOGIN=b run add epsilon
check "signing in as a stored account refused" '[[ $code == 1 && $out == *"already stored as beta"* ]]'
check "nothing stored, folder removed" '[[ ! -e $S/epsilon.account.json && -z $(find "$S" -name "login.*") ]]'
STUB_LOGIN=none run add zeta
check "no login: nothing changed" '[[ $code == 1 && $out == *"no login happened"* && ! -e $S/zeta.account.json ]]'
STUB_LOGIN=a run add alpha
check "add of the active account refused" '[[ $code == 1 && $out == *"is the active login"* && ! -e $S/alpha.credentials.json ]]'
echo '{"accountUuid":"cccccccc-0000-0000-0000-000000000000","emailAddress":"c@x"}' > "$S/gamma.account.json"
STUB_LOGIN=d run add gamma
check "signing in as another account than the name's refused" '[[ $code == 1 && $out == *"but gamma is c@x"* && $(jq -r .emailAddress "$S/gamma.account.json") == c@x && ! -e $S/gamma.credentials.json ]]'
check "no add wrote ~/.claude.json or the active token" '[[ $(sum "$HOME/.claude.json") == "$before" && $(active_tok) == tokA ]]'

echo "--- run: one session on an account's own login"
setup
before=$(sum "$HOME/.claude.json")
L=$S/beta.local
run run beta
check "no login yet and no terminal: refused" '[[ $code == 1 && $out == *"no login of its own yet"* ]]'
check "its config has no account record, no account caches, the rest kept" '[[ $(jq -c "[.oauthAccount, .cachedGrowthBookFeatures, .groveConfigCache, .numStartups, .hasCompletedOnboarding, .projects.p.hasTrustDialogAccepted, .projects.p.hasUnseenTeamArtifacts]" "$L/.claude.json") == "[null,null,null,5,true,true,null]" ]]'
check "projects with memory, skills and CLAUDE.md are links to ~/.claude" '[[ -L $L/projects && $(cat "$L/projects/p/memory/m.md") == "memory note" && -L $L/skills && -L $L/CLAUDE.md ]]'
check "settings.json is a file of its own with the shared settings" '[[ -f $L/settings.json && ! -L $L/settings.json && $(jq -c . "$L/settings.json") == "{\"model\":\"opus\"}" ]]'
check "folder and config readable by you only" '[[ $(stat -c %a "$L") == 700 && $(stat -c %a "$L/.claude.json") == 600 ]]'
STUB_LOGIN=b run_tty run beta --resume x
check "first start in a terminal: exit 0" '[[ $code == 0 ]]'
check "signed in there, the stored email filled in" '[[ $(grep "^auth" "$HOME/stub.log" | tail -n 1) == "auth config=$L secure=unset global= args=auth login --claudeai --email b@x" ]]'
check "then the session started there, with the arguments" '[[ $(last_log) == "session config=$L secure=unset global= args=--resume x" ]]'
check "its token is a plain file of its own" '[[ -f $L/.credentials.json && ! -L $L/.credentials.json && $(tok "$L/.credentials.json") == tokB2 ]]'
check "the stored beta token is still there for the global switch" '[[ $(tok "$S/beta.credentials.json") == tokB ]]'
check "the global login and ~/.claude.json untouched" '[[ $(active_tok) == tokA && $(sum "$HOME/.claude.json") == "$before" ]]'
STUB_LOGIN=none run run beta -c
check "a later start needs no terminal and no login" '[[ $code == 0 && $(last_log) == "session config=$L secure=unset global= args=-c" ]]'
CLAUDE_SECURESTORAGE_CONFIG_DIR=$HOME/elsewhere run run beta
check "a token folder set by the caller is not passed on" '[[ $code == 0 && $(last_log) == "session config=$L secure=unset global= args=" ]]'
run
check "status lists the run folder and its login" '[[ $out == *"local:  beta (b@x)"* ]]'

echo "--- run: links stay links"
echo '{"x":1}' > "$L/keybindings.json"
run run beta
check "a file a session made first moves to ~/.claude and is linked" '[[ -L $L/keybindings.json && $(jq -c . "$HOME/.claude/keybindings.json") == "{\"x\":1}" ]]'
rm "$L/CLAUDE.md"
echo "own" > "$L/CLAUDE.md"
run run beta
check "one that differs from ~/.claude is reported and left alone" '[[ $code == 0 && $out == *"CLAUDE.md is not shared"* && $(cat "$L/CLAUDE.md") == own && $(cat "$HOME/.claude/CLAUDE.md") == "global instructions" ]]'

echo "--- run: arguments for claude"
setup
run run beta --version
check "--version needs no login and goes straight to claude" '[[ $code == 0 && $(last_log) == "session config=$L secure=unset global= args=--version" && $(grep -c "^auth" "$HOME/stub.log") == 0 ]]'
run run beta mcp list
check "so do subcommands such as mcp" '[[ $code == 0 && $(last_log) == "session config=$L secure=unset global= args=mcp list" ]]'
STUB_LOGIN=b run_tty run beta "fix the tests"
check "a call that begins with a prompt leaves the sign-in to claude" '[[ $code == 0 && $(last_log) == "session config=$L secure=unset global= args=fix the tests" && $(grep -c "^auth" "$HOME/stub.log") == 0 ]]'
STUB_LOGIN=b run_tty run beta -- --model team-model -c
check "options start a session: sign in first, then pass them on, without the --" '[[ $code == 0 && $(grep -c "^auth" "$HOME/stub.log") == 1 && $(last_log) == "session config=$L secure=unset global= args=--model team-model -c" ]]'

echo "--- run: the model is the folder's own, every other setting shared"
model_pick() { jq ".model = \"$1\"" "$L/settings.json" > "$HOME/x" && mv "$HOME/x" "$L/settings.json"; }
model_pick team-model
run run beta
check "a model picked with /model stays the folder's own" '[[ $code == 0 && $(jq -r .model "$L/settings.json") == team-model && $(jq -r .model "$S/beta.local/.settings-own.json") == team-model ]]'
check "and never reaches the shared settings" '[[ $(jq -c . "$HOME/.claude/settings.json") == "{\"model\":\"opus\"}" ]]'
jq '.theme = "dark"' "$L/settings.json" > "$HOME/x" && mv "$HOME/x" "$L/settings.json"
run run beta
check "any other change a session made goes back to the shared settings" '[[ $code == 0 && $(jq -c . "$HOME/.claude/settings.json") == "{\"model\":\"opus\",\"theme\":\"dark\"}" && $(jq -r .model "$L/settings.json") == team-model ]]'
check "and the shared file keeps its permissions" '[[ $(stat -c %a "$HOME/.claude/settings.json") == 644 ]]'
jq '.env = {"X": "1"}' "$HOME/.claude/settings.json" > "$HOME/x" && mv "$HOME/x" "$HOME/.claude/settings.json"
run run beta
check "a shared change reaches the folder, its own model stays" '[[ $(jq -c "[.env.X, .model, .theme]" "$L/settings.json") == "[\"1\",\"team-model\",\"dark\"]" ]]'
jq '.theme = "light"' "$L/settings.json" > "$HOME/x" && mv "$HOME/x" "$L/settings.json"
jq '.theme = "solarized"' "$HOME/.claude/settings.json" > "$HOME/x" && mv "$HOME/x" "$HOME/.claude/settings.json"
run run beta
check "a setting changed on both sides keeps the shared value and says so" '[[ $out == *"kept the shared value of theme"* && $(jq -r .theme "$HOME/.claude/settings.json") == solarized && $(jq -r .theme "$L/settings.json") == solarized ]]'
jq 'del(.model)' "$L/settings.json" > "$HOME/x" && mv "$HOME/x" "$L/settings.json"
run run beta
check "back to the default model: the folder follows the shared one again" '[[ $(jq -r .model "$L/settings.json") == opus && $(jq -c . "$S/beta.local/.settings-own.json") == "{}" ]]'
echo 'not json' > "$L/settings.json"
before=$(sum "$HOME/.claude/settings.json")
run run beta
check "an unreadable folder file is reported, rebuilt and changes nothing shared" '[[ $out == *"not valid JSON"* && $(sum "$HOME/.claude/settings.json") == "$before" && $(jq -r .model "$L/settings.json") == opus ]]'
ln -sf "$HOME/.claude/settings.json" "$L/settings.json"
run run beta
check "a link from an earlier clacc becomes a file, the shared one untouched" '[[ -f $L/settings.json && ! -L $L/settings.json && $(sum "$HOME/.claude/settings.json") == "$before" ]]'

echo "--- run: refusals"
setup
STUB_LOGIN=d run_tty run beta
check "a login of another account starts no session" '[[ $code == 1 && $out == *"is d@x in no organisation, not b@x in org-b"* && $(grep -c "^session" "$HOME/stub.log") == 0 ]]'
run run beta
check "and keeps refusing until that login is removed" '[[ $code == 1 && $out == *"rm $S/beta.local/.credentials.json"* ]]'
rm "$S/beta.local/.credentials.json"
STUB_LOGIN=b2 run_tty run beta
check "the right account in another organisation starts no session either" '[[ $code == 1 && $out == *"is b@x in org-x, not b@x in org-b"* && $(grep -c "^session" "$HOME/stub.log") == 0 ]]'
rm "$S/beta.local/.credentials.json"
STUB_LOGIN=b0 run_tty run beta
check "the right account with no organisation recorded yet is accepted" '[[ $code == 0 && $(last_log) == "session config=$S/beta.local secure=unset global= args=" ]]'
: > "$HOME/stub.log"
STUB_LOGIN=none run run alpha auth status
check "auth commands pass through without a login" '[[ $code == 0 && $(last_log) == "auth config=$S/alpha.local secure=unset global= args=auth status" ]]'
STUB_LOGIN=none run_tty run gamma
check "no login in the browser: no session" '[[ $code == 1 && $out == *"no login happened"* && $(grep -c "^session" "$HOME/stub.log") == 0 ]]'
run run ../x
check "a path as name refused" '[[ $code == 1 && ! -e $S/../x.local ]]'
run run
check "run without a name: usage" '[[ $code == 2 ]]'
STUB_LOGIN=d run_tty run delta
check "a name with no stored account takes any login" '[[ $code == 0 && $(last_log) == "session config=$S/delta.local secure=unset global= args=" ]]'
check "the global login untouched by all of it" '[[ $(active_tok) == tokA && $(rec) == a@x ]]'

echo "--- Claude Code in another folder (CLAUDE_CONFIG_DIR)"
setup
C=$HOME/custom
mkdir -p "$C"
echo '{"claudeAiOauth":{"accessToken":"tokC","refreshToken":"refC"}}' > "$C/.credentials.json"
echo '{"oauthAccount":{"accountUuid":"aaaaaaaa-0000-0000-0000-000000000000","emailAddress":"a@x"}}' > "$C/.claude.json"
CLAUDE_CONFIG_DIR=$C run switch beta
check "the switch works on that folder" '[[ $code == 0 && $(tok "$C/.credentials.json") == tokB && $(jq -r .oauthAccount.emailAddress "$C/.claude.json") == b@x && $(tok "$S/alpha.credentials.json") == tokC ]]'
check "and leaves the default folder alone" '[[ $(active_tok) == tokA && $(rec) == a@x ]]'
echo '{"model":"sonnet"}' > "$C/settings.json"
CLAUDE_CONFIG_DIR=$C STUB_LOGIN=b run_tty run beta
check "a run session there links to that folder and names it to the session" '[[ $code == 0 && $(readlink "$S/beta.local/projects") == "$C/projects" && $(jq -r .model "$S/beta.local/settings.json") == sonnet && $(last_log) == "session config=$S/beta.local secure=unset global=$C args=" ]]'
CLAUDE_CONFIG_DIR=$S/beta.local CLACC_CLAUDE_CONFIG_DIR=$C run
check "clacc inside that session still sees the folder it came from" '[[ $out == *"active: beta (b@x)"* ]]'
CLAUDE_CONFIG_DIR=$S/beta.local CLACC_CLAUDE_CONFIG_DIR='' run
check "and a session from the default folder sees the default one" '[[ $out == *"active: alpha (a@x)"* ]]'
CLAUDE_CONFIG_DIR=$S/beta.local run
check "a run folder alone in CLAUDE_CONFIG_DIR, as in a spawned helper, means the default one" '[[ $out == *"active: alpha (a@x)"* ]]'

echo "--- rename"
setup
run rename beta work
check "rename the stored account moves record and token" '[[ $code == 0 && -f $S/work.account.json && $(tok "$S/work.credentials.json") == tokB && ! -e $S/beta.account.json && ! -e $S/beta.credentials.json ]]'
run rename alpha home
check "rename the active account" '[[ $code == 0 && $("$script") == *"active: home (a@x)"* && $("$script") == *"stored: work (b@x)"* ]]'
run switch work
check "switch under the new names" '[[ $code == 0 && $(active_tok) == tokB && -f $S/home.credentials.json ]]'
run rename home work
check "a taken name is refused" '[[ $code == 1 && $out == *"already taken"* && -f $S/home.account.json ]]'
run rename nosuch x
check "an unknown name is refused" '[[ $code == 1 && $out == *"no stored account"* ]]'
run rename home ../x
check "a path as new name is refused" '[[ $code == 1 && -f $S/home.account.json ]]'
run rename home run
check "a command word is a fine name, since a name always follows a command" '[[ $code == 0 && -f $S/run.account.json && ! -e $S/home.account.json ]]'
run switch run
check "and can be switched to" '[[ $code == 0 && $(active_tok) == tokA && $(rec) == a@x ]]'
check "no lock left behind" no_locks

echo "--- $fails of $checks checks failed"
exit $((fails > 0))
