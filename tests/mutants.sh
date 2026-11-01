#!/usr/bin/env bash
# Break one safeguard of clacc or its installer per copy and check that tests/run.sh catches every one.
# Usage: tests/mutants.sh
# The sed programs match the source text, $ signs included.
# shellcheck disable=SC2016
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
src=$(cd "$here/.." && pwd)/clacc
installer=$(cd "$here/.." && pwd)/install.sh
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Each sed program removes or weakens one safeguard. The optional arguments name another file to
# break and the variable that hands its copy to tests/run.sh.
mutant() {
  local name=$1 from=${3:-$src} var=${4:-CLACC}
  sed "$2" "$from" > "$work/$name"
  chmod +x "$work/$name"
  if cmp -s "$from" "$work/$name"; then
    echo "stale  $name: its edit no longer applies to $(basename "$from")" > "$work/$name.result"
    return
  fi
  (
    if env "$var=$work/$name" "$here/run.sh" > "$work/$name.out" 2>&1; then
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
mutant add-leaves-login-folder 's|^  rm -rf "\$login_dir" "\$login_dir.lock"$|  :|'
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
mutant keychain-leaves-login-item '/^  if \[\[ -n \$keychain_user \]\]; then keychain_delete "\$login_dir/d'
mutant keychain-ignores-config-folder 's|^  if \[\[ \$1 == "\$token" \&\& -z \$global \]\]; then|  if [[ $1 == "$token" ]]; then|'
mutant keychain-parks-in-files 's|^    keychain_write "\$store/\$current.credentials.json" "\$active"|    echo "$active" > "$store/$current.credentials.json"|'
mutant lock-by-the-written-path 's|^  real=\$(cd -P .*|  real=$claude_dir|'
mutant pick-ignores-the-week 's#^  week=\$(sed .*#  week=#'
mutant pick-ignores-five-hours 's#^  hours=\$(sed .*#  hours=#'
mutant pick-counts-a-limit-on-one-model 's#Current week (all models): #Current week ([^)]*): #'
mutant pick-takes-the-least 's#((left > best))#((best < 0 || left < best))#'
mutant pick-takes-a-used-up-account '/^  ((best > 0)) || die/d'
mutant pick-talks-on-stdout 's#most headroom: \$picked" >\&2#most headroom: $picked"#'
mutant tie-moves-away 's#if ((left > best)) || { ((left == best)) \&\& \[\[ \$name == "\$current" \]\]; }; then#if ((left > best)); then#'
mutant switch-counts-run-folder-login 's#^    elif has_token "\$own" \&\& .*#    elif has_token "$own"; then#'
mutant run-needs-a-name 's#^    "" | -\*)$#    "")#'
mutant no-limit-counts-as-all-free 's#^  \[\[ -n \$hours\$week \]\] || return 1$#  :#'
mutant limit-past-its-end-goes-negative 's#^  if ((tightest > 100)); then tightest=100; fi$#  :#'
mutant reading-in-the-project-folder 's#^    cd "\$store"$#    :#'
mutant reading-keeps-the-callers-folder 's#; else unset CLAUDE_CONFIG_DIR; fi#; fi#'
mutant reading-saves-a-session 's# --no-session-persistence##'
mutant reading-runs-hooks 's# --safe-mode##'
mutant reading-on-the-sessions-model 's# --model haiku##'
mutant reading-ignores-the-run-folder 's#^    elif has_token "\$own" \&\& .*#    elif false; then#'
mutant reading-without-the-lock '/^read_parked() {$/,/^}$/ s#^  take_lock "\$lent_lock"$#  :#'
mutant reading-keeps-the-lock '/^read_parked() {$/,/^}$/ s#^  unlock_all$#  :#'
mutant switch-ignores-a-reading 's#for lock in "\$lent_lock" #for lock in #'
mutant lent-token-left-behind 's#^  if \[\[ -n \$lent \]\] \&\& has_token .*#  :#'
mutant stopped-reading-loses-the-token '/^cleanup() {$/,/^}$/ s#^  close_login_dir$#  :#'
install_mutant() { mutant "$1" "$2" "$installer" CLACC_INSTALLER; }
install_mutant install-from-the-github-page 's|raw.githubusercontent.com/zauberzeug/clacc/main/clacc|github.com/zauberzeug/clacc/blob/main/clacc|'
install_mutant install-no-chmod '/^  chmod +x "\$new"$/d'
install_mutant install-unchecked-download '/--help > \/dev\/null || {$/,/^  }$/d'
install_mutant install-over-the-old-one 's|^new=.*|new=$bin/clacc|'
install_mutant install-leaves-temporary-file '/^trap /d'
install_mutant install-runs-while-cut-off '/^main() {$/d; /^}$/d; /^main$/d'
wait
sort "$work"/*.result
# Reading the log of a CI run takes admin rights, while its annotations are public.
if [[ -n ${GITHUB_ACTIONS:-} ]]; then grep -hv '^caught' "$work"/*.result | sed 's/^/::error::/'; fi
! grep -qv '^caught' "$work"/*.result
