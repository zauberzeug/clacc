---
name: add-feature
description: 'Plan and implement a whole new feature of clacc: requirement, test first, simplification, review, verification and push. Use when someone wants the full process for something bigger: "add a feature", "plan and build X", "implement this completely". For the requirement alone, without any implementation, use define-requirement.'
argument-hint: <what the feature should do>
---

Read `README.md`, `REQUIREMENTS.md`, `CONTRIBUTING.md` and `AGENTS.md` first.

Think about how the feature fits the whole of clacc, and offer at least three approaches with their pros and cons, unless the request already settles it.
Recommend one, and ask about whatever is ambiguous before you start.

Then, in this order:

1. Run the skill `define-requirement`. New requirements start as `planned`.
2. Write the failing checks in `tests/run.sh`, under a heading that names the requirement, and see them fail for the right reason.
3. Implement in small steps until they pass.
   Changing a check in the light of what you learn is fine, as long as the requirement stays in step.
   Every green, self-contained step can be committed and pushed.
4. Add a mutant for every new safeguard.
5. Simplify the code.
6. Update `README.md` and `usage` in `clacc`, if a person can see the change.
7. Run the skill `review` and fix what it finds.
8. Run the skill `verify-requirement`, which flips the status to `active`.
9. Run the skill `commit`.

Open a pull request instead of pushing to `main` when someone asked for one or when the feature needs a discussion first, and follow the skill `collaboration`.
