---
name: commit
description: 'Review the current changes, run the gate, commit them with a message following CONTRIBUTING.md and push to main. Use for "commit", "commit this", "push this", "check das ein", "mach einen Commit", and after each green, self-contained step of mainline work. Never amends, never force-pushes, never skips a hook. For a deeper look at the changes first, use review.'
---

Read the sections on commit messages in `CONTRIBUTING.md` and on mainline development and parallel sessions in `AGENTS.md` first.

1. Run `git status --short` and `git diff`, and separate your changes from any you do not recognize, which you leave alone.
2. Review the diff briefly by `REVIEW.md`, and fix what is wrong.
3. Run `make check`, with its output in a file and with a long timeout or in the background, and read the exit code.
   For a change of Markdown alone, `make lint` is enough.
4. Stage new files by name, and commit explicit paths: `git commit -m "..." -- <paths>`.
   Give the message an imperative subject, and let the body say what the diff cannot.
   Boy scout cleanup goes into a commit of its own.
5. Run `git fetch`, and `git merge origin/main` if `main` moved, and resolve by meaning.
6. Push with `git push origin HEAD:main`, again with a long timeout or in the background, because the push gate runs `make check` on a clean copy (R-028).
7. Watch CI with the command in `AGENTS.md`.
   A red `main` is your next job.

Never use `--amend`, a force-push, a rebase or `--no-verify`.
On a branch for a pull request, the same steps hold, and the skill `collaboration` covers the text.
