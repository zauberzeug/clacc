---
type: behavior
tags: [install, update]
status: active
---

# An update brings the newest clacc

`clacc update` downloads `clacc` from `main` and puts it in place of the file it runs from, so whatever lands on `main` reaches users (R-028).
It says `clacc is up to date` when the two are the same.

The new file keeps the permissions of the old one.
It takes the old one's place by a rename, because bash reads a script while it runs: a clacc running at that moment keeps reading the old file.

A download replaces the file only when its `--help` starts with the word `clacc`.
So a failed download, a web page, an empty file or a file cut off keeps the old file and leaves no temporary file.
Copies already installed test every later download this way, so the first word of `--help` stays `clacc`.

clacc replaces only an installed copy, and refuses anything else without changing it:

- a link,
- a file in a folder with a `.git`, which `git pull` keeps up to date,
- a clacc read from standard input or sourced, which has no file of its own,
- a file in a folder that clacc cannot write to.

An update needs `curl`, and neither `jq` nor the store (R-007).
