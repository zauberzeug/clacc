---
type: behavior
tags: [run, settings, safety]
status: active
---

# Settings stay off the command line

`clacc run` keeps every value of the settings off the command line of the tools it calls, whether the value comes from the shared file or from the run folder.
Settings can hold secrets, such as an API key under `env`, and other processes on the machine can read a command line for as long as the tool runs.
