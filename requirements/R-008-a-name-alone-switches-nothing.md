---
type: cli
tags: [cli, switch]
status: active
---

# A name alone switches nothing

`clacc <name>` moves no session.
It exits with 2 and lists the commands, and when the name is stored it adds the command that would move every session: `clacc switch <name>`.

Moving every session takes the explicit command, because a slip of the keyboard must not move every session.
