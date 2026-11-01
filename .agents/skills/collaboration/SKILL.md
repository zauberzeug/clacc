---
name: collaboration
description: 'Work with other people on GitHub: write or rework a pull request description, post or edit a comment in an issue or pull request thread, tick a checkbox. Use whenever a pull request is opened or its text rewritten, or when results or a decision go back to an issue: "open the PR", "write the PR text", "comment on the issue", "reply in the PR", "tick the box". Not for reviewing code (review) or for commits (commit).'
---

Everything here is in English ([CONTRIBUTING.md](../../../CONTRIBUTING.md)).
One rule for every reader: write what the other person cannot find out from the repository.

**Posting is outward-facing and hard to take back, so get an explicit go for it.**

# Pull request descriptions

The text says what the branch delivers in its current state, not how it got there.
A conflict, a review round or a merge of `main` belongs in a comment.
The squash merge makes the title the commit subject on `main` and this text the commit body, so write both to outlast the branch.

**Start with why.** The first paragraph says what was wrong or what could not be done, and why that mattered.
If the first sentence could be read off the diff, it is the wrong first sentence.

In this order:

1. **Why:** the problem, concretely: the failure, the requirement the code contradicted. Name the commit, issue or requirement that shows it.
2. **Changes:** the change in words, at the level the diff cannot express, with the requirement files it adds or changes.
3. **Deliberately unchanged:** what was left out and what the change costs.
   This is usually the most valuable part, and nobody can rebuild it from the diff.
4. **Decided along the way:** assumptions made where a requirement left a gap, and questions settled on the way.
5. **Verification:** what was run and what it showed.

Give evidence, not claims: "3 checks fail with `no stored account` without the fix" beats "added tests".
Keep what shows on opening short enough to read standing up, and fold the proof, never the claim:

```markdown
<details>
<summary>How the lock could go stale under load</summary>

...the mechanism, the trigger, the numbers...

</details>
```

Leave blank lines around the inner text, or GitHub renders it literally, and give `<summary>` a real sentence.

Never write in the second person, because someone will read this in six months who was not in the conversation.
Do not hard-wrap, because GitHub keeps your line breaks: one line per paragraph.
Link an issue with `Closes #<n>`.

# Threads in issues and pull requests

Other people's text belongs to them, so post your own comment instead of editing theirs.
The one exception is a task-list checkbox: tick `- [ ]` to `- [x]` in place, and change nothing else, not even a sentence the work just made stale.
Your own comments are yours to edit, but when something you wrote turns out wrong, a new comment saying what changed keeps the thread traceable and notifies people.

Tick only what is actually true: code that is written but not pushed leaves its box open.

While the work is still local, a status comment is premature, so open the pull request instead.
Comment in an issue only on what a pull request cannot carry: a question, a decision that needs a go before the work, or a finding that changes the premise of the issue.
Such a comment brings facts, options and their price, and your own view marked as yours.
It does not announce a decision the others have not made.

# Notes on gh

- `gh issue view <n>` can print nothing and still exit with 0 because of its pager, so set `GH_PAGER=cat` for reading calls.
- Read structured data: `gh issue view <n> --json body,comments -q .body`.
- Write from a file with `--body-file`, which keeps backticks and quotes intact.
- When you tick a box in someone else's text, fetch it, change only the box, and compare with a diff to show that nothing else moved.
