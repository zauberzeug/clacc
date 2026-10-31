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
declare -A mutant=(
  [park-without-link]='s|^  ln -f "\$token" "\$store/\$current.credentials.json"|  :|'
  [no-locks]='s|^  lock_all$|  :|'
  [no-chmod]='s|^  chmod 600 "\$store/\$target.credentials.json"|  :|'
  [no-record-swap]='s|^  set_record "\$store/\$target.account.json"$|  :|'
  [rename-keeps-token]='s|^  if \[\[ -f \$store/\$old.credentials.json \]\]; then mv .*|  :|'
  [no-token-write-lock]='s| "\$claude_dir/.storage-write.lock"||'
  [token-folder-passed-on]='/^unset CLAUDE_SECURESTORAGE_CONFIG_DIR/d'
  [no-run-account-check]='s|^  if \[\[ \${1:-} != auth \]\]; then check_local_account "\$name" "\$dir"; fi$|  :|'
  [run-check-ignores-org]='s#elif \$g.organizationUuid and#elif false and#'
  [seed-keeps-account-record]='s|^    del(.oauthAccount)$|    .|'
  [add-no-name-check]='s#^  \[\[ ! -f \$store/\$name.account.json || .*#  :#'
  [add-leaves-login-folder]='s|^  if \[\[ -n \$login_dir \]\]; then rm -rf .*|  :|'
  [projects-not-shared]='s|^shared_dirs=(projects |shared_dirs=(|'
  [add-login-in-shared-config]='s|CLAUDE_CONFIG_DIR=\$login_dir claude auth login|claude auth login|'
  [run-forgets-claude-folder]='/^  export CLACC_CLAUDE_CONFIG_DIR=/d'
  [run-folder-taken-as-claude-folder]='/^case \$global in/d'
  [model-shared-across-accounts]='s|^own_settings=.*|own_settings="[]"|'
  [session-settings-not-shared-back]='s|select(\$s\[.\] == \$b\[.\])\] as \$push|select(false)] as $push|'
  [run-signs-in-for-everything]='s#^    -h | --help | -v | --version) return 1 ;;#    -h | --help | -v | --version) return 0 ;;#; s#^    \*) return 1 ;;#    *) return 0 ;;#'
  [run-keeps-double-dash]='/^  if \[\[ \${1:-} == -- \]\]; then shift; fi$/d'
  [shared-settings-lose-permissions]='/^    chmod "\$mode" "\$shared"$/d'
)

for name in "${!mutant[@]}"; do
  sed "${mutant[$name]}" "$src" > "$work/$name"
  chmod +x "$work/$name"
  if cmp -s "$src" "$work/$name"; then
    echo "stale  $name: its edit no longer applies to clacc" > "$work/$name.result"
    continue
  fi
  (
    if CLACC=$work/$name "$here/run.sh" > "$work/$name.out" 2>&1; then
      echo "LIVED  $name" > "$work/$name.result"
    else
      echo "caught $name ($(grep -c '^FAIL' "$work/$name.out") checks failed)" > "$work/$name.result"
    fi
  ) &
done
wait
sort "$work"/*.result
! grep -qv '^caught' "$work"/*.result
