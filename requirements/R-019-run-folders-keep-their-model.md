---
type: behavior
tags: [run, settings]
status: active
---

# Run folders keep their model

A model picked with `/model` in a `run` session stays the default of that account, because accounts offer different models.
Every other setting is shared.

The `settings.json` of a run folder is a file of its own, rebuilt at every start from the shared settings and the model of the folder:

- A model a session picked stays in the folder and never reaches the shared settings.
- Going back to the default model makes the folder follow the shared model again.
- Any other change a session made goes back to the shared settings at the next start, and the shared file keeps its permissions.
- A setting changed on both sides keeps the shared value, and clacc says so.
- A folder file that is not valid JSON is reported and rebuilt, and the changes in it are dropped.
- A link from an earlier version of clacc becomes a file (R-003).
