---
type: cli
tags: [cli]
status: active
---

# Every command says how it ended

The exit code says how a command ended:

| Code | Meaning                                                                      |
| ---- | ---------------------------------------------------------------------------- |
| 0    | the command did what it says                                                 |
| 1    | clacc refused or failed, and a line on stderr beginning with `clacc:` says why |
| 2    | the command line is wrong, and the list of commands goes to stderr           |

`clacc run` hands over to claude when it starts one, so from then on the exit code is claude's.
A tool that fails underneath, such as `jq` on a broken file, stops clacc with that tool's message and exit code.

`clacc --help` prints the commands to stdout and exits with 0 on any system, without `jq` and without touching the store.
`clacc update` needs Linux or macOS, and neither `jq` nor the store (R-033).
Every other command needs Linux or macOS and `jq`, and exits with 1 without them.
