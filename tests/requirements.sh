#!/usr/bin/env bash
# Check the requirements list (R-029): name every problem on a line of its own, exit 1 when there is any.
# Usage: tests/requirements.sh [root]   (the root of a repository, by default this one)
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=${1:-$(cd "$here/.." && pwd)}
name_format='^R-[0-9]{3}-[a-z0-9-]+\.md$'
tags_format='^\[[a-z0-9-]+(, [a-z0-9-]+)*\]$'
sections=$(grep -hE '^echo "--- ' "$root"/tests/*.sh 2> /dev/null | grep -vF 'echo "--- $')
ids=" "
highest=0
problems=0

problem() {
  echo "$1"
  problems=$((problems + 1))
}

check_requirement() {
  local file=$1 name id end field type status tags
  name=$(basename "$file")
  if [[ ! $name =~ $name_format ]]; then
    problem "$name: the name must be an ID and a slug, such as R-009-switch-moves-every-session.md"
    return
  fi
  id=${name:0:5}
  if [[ $ids == *" $id "* ]]; then problem "$id: used twice"; fi
  ids+="$id "
  if ((10#${id:2} > highest)); then highest=$((10#${id:2})); fi
  end=$(awk 'NR > 1 && /^---$/ { print NR; exit }' "$file")
  if [[ $(head -n 1 "$file") != --- || -z $end ]]; then
    problem "$name: the front matter must start on the first line and end with ---"
    return
  fi
  while read -r field _; do
    case $field in
      type: | tags: | status:) ;;
      *) problem "$name: $field is not a field" ;;
    esac
  done < <(sed -n "2,$((end - 1))p" "$file")
  type=$(sed -n "2,$((end - 1))s/^type: *//p" "$file")
  status=$(sed -n "2,$((end - 1))s/^status: *//p" "$file")
  tags=$(sed -n "2,$((end - 1))s/^tags: *//p" "$file")
  case $type in
    concept | user-story | decision | behavior | cli | data-format) ;;
    *) problem "$name: $type is not a type" ;;
  esac
  case $status in
    active | planned | retired) ;;
    *) problem "$name: $status is not a status" ;;
  esac
  if [[ ! $tags =~ $tags_format ]]; then problem "$name: the tags must be a list such as [switch, macos]"; fi
  if [[ $(awk -v end="$end" 'NR > end && NF { print; exit }' "$file") != "# "* ]]; then problem "$name: the body must start with a # heading"; fi
  if [[ $status == active && " behavior cli data-format " == *" $type "* && $sections != *"$id"* ]]; then
    problem "$id: no section in the tests names this active $type"
  fi
}

for file in "$root"/requirements/*.md; do
  if [[ -e $file ]]; then check_requirement "$file"; fi
done
if ((highest == 0)); then problem "no requirements in $root/requirements"; fi
for ((number = 1; number <= highest; number++)); do
  id=$(printf 'R-%03d' "$number")
  if [[ $ids != *" $id "* ]]; then problem "$id: missing, as the IDs run without a gap"; fi
done
while read -r id; do
  if [[ $ids != *" $id "* ]]; then problem "$id: mentioned, but there is no such requirement"; fi
done < <(grep -rhowIE 'R-[0-9]{3}' "$root" --exclude-dir=.git --exclude-dir=tmp --exclude-dir=worktrees | sort -u)
while read -r section; do
  problem "this section of the tests names no requirement: $section"
done < <(grep -vE 'R-[0-9]{3}' <<< "$sections" | grep .)
exit $((problems > 0))
