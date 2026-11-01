---
type: decision
tags: [design]
status: active
---

# A single portable bash script

clacc is one bash script that needs only `jq` and the base tools of Linux and macOS.
Installing and updating it also take `curl` (R-025, R-033).
One file installs with one download (R-025), has nothing to build, and can be read in one sitting by anyone about to trust it with their logins.

It runs on the bash 3.2 that macOS ships, and with both BSD and GNU tools.
