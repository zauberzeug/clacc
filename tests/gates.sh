#!/usr/bin/env bash
# Exercise the gates of this repository on throwaway ones.
# Usage: tests/gates.sh   (CLACC_REQUIREMENTS=<path> tests another copy of the requirements check,
# and CLACC_STOP_AT_FAIL=1 ends the run at the first failing check)
# Each check is single-quoted on purpose and check() evaluates it, so shellcheck cannot see that
# the variables and helpers it uses are used (SC2317 in shellcheck 0.9, SC2329 from 0.10 on).
# shellcheck disable=SC2016,SC2034,SC2317,SC2329
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
requirements=${CLACC_REQUIREMENTS:-$here/requirements.sh}
# Without a temporary folder they stop, as in run.sh.
tmp=$(mktemp -d) || exit 1
HOME=$(cd "$tmp" && pwd -P) || exit 1
export HOME
trap 'rm -rf "$HOME"' EXIT
fails=0
checks=0

check() {
  checks=$((checks + 1))
  if eval "$2"; then
    echo "ok   $1"
  else
    echo "FAIL $1"
    fails=$((fails + 1))
    if [[ -n ${CLACC_STOP_AT_FAIL:-} ]]; then exit 1; fi
  fi
}

L=$HOME/list
R=$L/requirements
# A file of the list: <file name> <type> <tags> <status>
requirement() { printf -- '---\ntype: %s\ntags: %s\nstatus: %s\n---\n\n# A heading\n\nThe rule.\n' "$2" "$3" "$4" > "$R/$1"; }
# A clean list: a behavior that a section names, and a decision that needs no section.
clean_list() {
  rm -rf "$L"
  mkdir -p "$R" "$L/tests"
  requirement R-001-a-rule.md behavior '[a, b]' active
  requirement R-002-a-choice.md decision '[a]' active
  printf '%s\n' 'echo "--- a section (R-001)"' 'echo "--- $fails failed"' > "$L/tests/run.sh"
}
read_list() { out=$("$requirements" "$L" 2>&1); code=$?; }

echo "--- the requirements check (R-029)"
clean_list
read_list
check "a clean list passes in silence" '[[ $code == 0 && -z $out ]]'
clean_list
mv "$R/R-002-a-choice.md" "$R/R-002_a_choice.md"
read_list
check "a file name without an ID and a slug is named" '[[ $code == 1 && $out == *"R-002_a_choice.md: the name must be"* ]]'
clean_list
cp "$R/R-002-a-choice.md" "$R/R-002-the-same.md"
read_list
check "an ID used twice is named" '[[ $code == 1 && $out == *"R-002: used twice"* ]]'
clean_list
mv "$R/R-002-a-choice.md" "$R/R-003-a-choice.md"
read_list
check "a gap in the IDs is named" '[[ $code == 1 && $out == *"R-002: missing"* ]]'
clean_list
printf 'A line first\n---\ntype: decision\ntags: [a]\nstatus: active\n---\n\n# A heading\n' > "$R/R-002-a-choice.md"
read_list
check "front matter that does not start on the first line is named" '[[ $code == 1 && $out == *"R-002-a-choice.md: the front matter"* ]]'
clean_list
printf -- '---\ntype: decision\n\n# A heading\n' > "$R/R-002-a-choice.md"
read_list
check "and so is front matter that never ends" '[[ $code == 1 && $out == *"R-002-a-choice.md: the front matter"* ]]'
clean_list
printf -- '---\ntype: decision\ntags: [a]\nstatus: active\npriority: high\n---\n\n# A heading\n' > "$R/R-002-a-choice.md"
read_list
check "a field of its own is named" '[[ $code == 1 && $out == *"R-002-a-choice.md: priority: is not a field"* ]]'
clean_list
requirement R-002-a-choice.md wish '[a]' active
read_list
check "a type that is not listed is named" '[[ $code == 1 && $out == *"R-002-a-choice.md: wish is not a type"* ]]'
clean_list
requirement R-002-a-choice.md decision '[a]' finished
read_list
check "a status that is not listed is named" '[[ $code == 1 && $out == *"R-002-a-choice.md: finished is not a status"* ]]'
for tags in 'a, b' '[]' '[a,b]'; do
  clean_list
  requirement R-002-a-choice.md decision "$tags" active
  read_list
  check "the tags $tags are named" '[[ $code == 1 && $out == *"R-002-a-choice.md: the tags must be"* ]]'
done
clean_list
printf -- '---\ntype: decision\ntags: [a]\nstatus: active\n---\n\nJust text.\n' > "$R/R-002-a-choice.md"
read_list
check "a body that does not start with a heading is named" '[[ $code == 1 && $out == *"R-002-a-choice.md: the body must"* ]]'
clean_list
echo "see R-009" > "$L/README.md"
read_list
check "a mention without a file is named" '[[ $code == 1 && $out == *"R-009: mentioned"* ]]'
clean_list
echo "FOOBAR-009" > "$L/README.md"
mkdir -p "$L/.git" "$L/tmp" "$L/.claude/worktrees/x"
for folder in .git tmp .claude/worktrees/x; do echo "see R-009" > "$L/$folder/notes"; done
read_list
check "another word that ends alike is no mention, and git and scratch folders do not count" '[[ $code == 0 && -z $out ]]'
clean_list
printf '%s\n' 'echo "--- without one"' >> "$L/tests/run.sh"
read_list
check "a section that names no requirement is named" '[[ $code == 1 && $out == *"names no requirement: echo \"--- without one\""* ]]'
for type in behavior cli data-format; do
  clean_list
  requirement R-002-a-choice.md "$type" '[a]' active
  read_list
  check "an active $type that no section names is named" '[[ $code == 1 && $out == *"R-002: no section"* ]]'
done
clean_list
requirement R-003-later.md behavior '[a]' planned
requirement R-004-given-up.md cli '[a]' retired
read_list
check "a planned or retired one needs no section" '[[ $code == 0 && -z $out ]]'
clean_list
requirement R-003-elsewhere.md behavior '[a]' active
printf '%s\n' 'echo "--- another script (R-003)"' > "$L/tests/other.sh"
read_list
check "a section in any of the test scripts counts" '[[ $code == 0 && -z $out ]]'
clean_list
rm "$R"/*
read_list
check "a list with no requirements at all fails" '[[ $code == 1 && $out == *"no requirements"* ]]'
out=$("$requirements" "$repo" 2>&1)
code=$?
check "this repository passes it" '[[ $code == 0 && -z $out ]]'

echo "--- $fails of $checks checks failed"
exit $((fails > 0))
