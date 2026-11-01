---
name: define-requirement
description: 'Turn a described change into a requirement file in requirements/ before any code is written, and report related or conflicting requirements. Use when someone wants new or changed behavior: "add a feature", "implement X", "change how Y works", "it should behave like", "new requirement", "neue Anforderung". Runs before any implementation and never implements. Verification is verify-requirement.'
argument-hint: <what should change>
---

Read `REQUIREMENTS.md` first.

Turn the described change into a clear requirement, before anything is implemented.

1. Understand what should hold, and ask rather than guess when it is unclear.
2. Search `requirements/` by tags and keywords for related requirements, and sort each hit:
   - **already covered:** edit that file instead of adding a new one, because the ID names the requirement, not its wording.
   - **touched, but consistent:** mention its ID in the new text.
   - **in conflict:** say so.
     The conflicting requirement must be edited or retired on purpose in the same change, and never left standing wrong.
3. Write or update the file:
   - A new requirement takes the highest ID plus one, a short slug and `status: planned`.
   - A change to an existing requirement is made in place, and its status stays `active`.
   - Follow "Write it to be understood at first reading" in `REQUIREMENTS.md`.
     When you change an existing sentence, read it again with the code, as "Keep the meaning when rewriting" asks.
4. Run `tests/requirements.sh`.
5. Report the file, the related IDs, and any conflict with a proposed solution.

The conflict check is advisory: report and propose, and leave the decision to the person who asked.
Implement nothing, because implementation and verification are steps of their own.
