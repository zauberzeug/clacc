#!/usr/bin/env bash
# Install clacc into ~/.local/bin, or update it there. https://github.com/zauberzeug/clacc
#   curl -fsSL https://raw.githubusercontent.com/zauberzeug/clacc/main/install.sh | bash
set -euo pipefail

bin=$HOME/.local/bin
new=$bin/clacc.tmp.$$
trap 'rm -f "$new"' EXIT

# Only the last line of this file starts anything, so a download cut short does nothing.
main() {
  mkdir -p "$bin"
  curl -fsSL https://raw.githubusercontent.com/zauberzeug/clacc/main/clacc -o "$new"
  chmod +x "$new"
  # Whatever does not run, such as a web page, never replaces a clacc that does.
  "$new" --help > /dev/null || {
    echo "clacc: the download does not run; nothing changed" >&2
    exit 1
  }
  mv -f "$new" "$bin/clacc"
  echo "installed clacc in $bin"
  case :$PATH: in
    *:"$bin":*) ;;
    *) echo "add $bin to your PATH to run clacc by its name" ;;
  esac
}

main
