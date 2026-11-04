---
type: behavior
tags: [accounts, run, terminal]
status: active
---

# A sign-in turns off terminal reports

Right before clacc signs in to an account, it tells the terminal to stop its reports of mouse clicks and moves, of focus changes and of where a paste begins and ends.
clacc signs in for `add` (R-013) and for the first start of `run` (R-015).

A terminal sends each report as a short code among the keys a person types, such as `\e[<0;83;9M` for a click.
A Claude Code session can leave these reports on when it ends.
Each report that comes while the sign-in waits would then land in the pasted code, and the sign-in would refuse that code as incomplete.
A program that wants the reports, such as Claude Code itself, turns them on again.

When the input or the output of clacc is not a terminal, for example when the output goes to a file, clacc sends none of these codes.
