---
name: analyze
description: 'Explain a bug or strange behavior of clacc and offer possible causes, checking the tests and requirements for assumptions nobody stated. Use when someone reports something wrong or puzzling: "why does", "strange", "bug", "this is odd", "does not work", "warum", "funktioniert nicht". Read-only: it changes nothing. A fix that follows starts with define-requirement or a failing check; otherwise the finding becomes an issue.'
argument-hint: <the bug or strange behavior>
---

Read `AGENTS.md`, `README.md` and `REQUIREMENTS.md` first.

Analyze the bug or strange behavior described by the caller, and change nothing.

1. Say what should happen according to `requirements/`, and whether any requirement covers this case at all.
2. Read the code path, in `clacc` and in the stand-ins of `tests/stub/`.
3. Offer the possible explanations, most likely first, each with what speaks for and against it.
4. Check the tests and the requirements for assumptions nobody stated, such as a stand-in that behaves differently from the real Claude Code (R-024).
5. Say how to tell the explanations apart.
   Reproduce in the throwaway setup of the tests, and leave anything that needs a real login to a person (R-026).
