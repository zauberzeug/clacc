---
type: user-story
tags: [accounts]
status: active
---

# Move between accounts without a new login

A person with several Claude Code accounts moves between them without signing in again and without restarting a session.
For example, someone who reaches the usage limit of a personal subscription continues on a company subscription with one command.

Claude Code itself keeps one login per machine.
Signing in with `/login` replaces that login, so every move would mean a browser login and a restart of every open session.

clacc offers two moves: every session at once (R-009), or one new session while all others stay where they are (R-015).
