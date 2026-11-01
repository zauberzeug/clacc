---
type: behavior
tags: [workflow, tests]
status: active
---

# The requirements list checks itself

`tests/requirements.sh` names every problem on a line of its own and exits with 1 when there is any:

- a file name that is not an ID plus a slug, or an ID used twice,
- a gap in the IDs, which run from R-001 to the highest,
- front matter that does not start on the first line, holds another field than `type`, `tags` and `status`, or a value [REQUIREMENTS.md](../REQUIREMENTS.md) does not list,
- a body that does not start with a `# ` heading,
- a mention of an ID anywhere in the repository without a file,
- a section heading in the tests that names no requirement,
- an active requirement of the type `behavior`, `cli` or `data-format` that no section names.

A list with no requirements at all is a problem too, so a wrong path cannot pass as a clean list.
