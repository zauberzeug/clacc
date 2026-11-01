#!/usr/bin/env bash
# Break one safeguard of clacc per copy and check that tests/run.sh catches every one.
# Usage: tests/mutants.sh
# The sed programs match clacc's source text, $ signs included.
# shellcheck disable=SC2016
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
src=$(cd "$here/.." && pwd)/clacc
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Each sed program removes or weakens one safeguard.
mutant() {
  local name=$1
  sed "$2" "$src" > "$work/$name"
  chmod +x "$work/$name"
  if cmp -s "$src" "$work/$name"; then
    echo "stale  $name: its edit no longer applies to clacc" > "$work/$name.result"
    return
  fi
  (
    if CLACC=$work/$name "$here/run.sh" > "$work/$name.out" 2>&1; then
      echo "LIVED  $name" > "$work/$name.result"
    else
      echo "caught $name ($(grep -c '^FAIL' "$work/$name.out") checks failed)" > "$work/$name.result"
    fi
  ) &
}

mutant park-without-link 's|^  ln -f "\$token" "\$store/\$current.credentials.json"|  :|'
mutant no-locks 's|^  lock_all$|  :|'
mutant no-chmod 's|^  chmod 600 "\$store/\$target.credentials.json"|  :|'
mutant no-record-swap 's|^  set_record "\$store/\$target.account.json"$|  :|'
mutant rename-keeps-token 's|^  if has_token "\$store/\$old.credentials.json"; then move_token .*|  :|'
mutant no-token-write-lock 's| "\$claude_dir/.storage-write.lock"||'
mutant token-folder-passed-on '/^unset CLAUDE_SECURESTORAGE_CONFIG_DIR/d'
mutant no-run-account-check 's|^  if \[\[ \${1:-} != auth \]\]; then check_local_account "\$name" "\$dir"; fi$|  :|'
mutant run-check-ignores-org 's#elif \$g.organizationUuid and#elif false and#'
mutant seed-keeps-account-record 's|^    del(.oauthAccount)$|    .|'
mutant add-no-name-check 's#^  \[\[ ! -f \$store/\$name.account.json || .*#  :#'
mutant add-leaves-login-folder 's|^  if \[\[ -n \$login_dir \]\]; then rm -rf .*|  :|'
mutant projects-not-shared 's|^shared_dirs=(projects |shared_dirs=(|'
mutant add-login-in-shared-config 's|CLAUDE_CONFIG_DIR=\$login_dir claude auth login|claude auth login|'
mutant run-forgets-claude-folder '/^  export CLACC_CLAUDE_CONFIG_DIR=/d'
mutant run-folder-taken-as-claude-folder '/^case \$global in/d'
mutant model-shared-across-accounts 's|^own_settings=.*|own_settings="[]"|'
mutant session-settings-not-shared-back 's|select(\$s\[.\] == \$b\[.\])\] as \$push|select(false)] as $push|'
mutant run-signs-in-for-everything 's#^    -h | --help | -v | --version) return 1 ;;#    -h | --help | -v | --version) return 0 ;;#; s#^    \*) return 1 ;;#    *) return 0 ;;#'
mutant run-keeps-double-dash '/^  if \[\[ \${1:-} == -- \]\]; then shift; fi$/d'
mutant shared-settings-lose-permissions '/^    chmod "\$mode" "\$shared"$/d'
mutant bare-name-switches 's|^      usage$|      switch "$1"|'
mutant name-refuses-a-dot 's|\[a-z0-9._-\]|[a-z0-9_-]|'
mutant name-may-begin-with-a-dot 's|=~ ^\[a-z0-9\]|=~ ^[a-z0-9.]|'
mutant name-may-hold-a-slash 's|\[a-z0-9._-\]|[a-z0-9._/-]|'
mutant keychain-write-unchecked '/^  \[\[ \$(read_token "\$1") == "\$2" \]\] || die/d'
mutant keychain-long-line-on-stdin 's|^  if ((\${#line} <= 4032)); then|  if true; then|'
mutant keychain-keeps-the-old-place 's|^  keychain_delete "\$1" .*|  :|'
mutant keychain-prints-hex 's|^  if \[\[ \$value =~ .*|  :|'
mutant keychain-leaves-login-item '/^  if \[\[ -n \$login_dir && -n \$keychain_user \]\]/d'
mutant keychain-ignores-config-folder 's|^  if \[\[ \$1 == "\$token" \&\& -z \$global \]\]; then|  if [[ $1 == "$token" ]]; then|'
mutant keychain-parks-in-files 's|^    keychain_write "\$store/\$current.credentials.json" "\$active"|    echo "$active" > "$store/$current.credentials.json"|'
mutant lock-by-the-written-path 's|^  real=\$(cd -P .*|  real=$claude_dir|'
wait
sort "$work"/*.result
! grep -qv '^caught' "$work"/*.result
