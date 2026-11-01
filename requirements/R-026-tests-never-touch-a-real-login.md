---
type: decision
tags: [tests, safety]
status: active
---

# Tests never touch a real login

The tests run in a throwaway home folder, with stand-ins for `claude`, `security`, `uname`, `curl` and `sleep` first on the `PATH`.
When the `security` they find is not the stand-in, they stop, so no test can reach the real Keychain.
Without a temporary folder they stop too, because they delete their home folder again and again.

The stand-ins also take the clock out of the checks.
A check counts waits instead of timing them, so its result does not depend on how fast the machine runs.

The commands of clacc that change a login are for a person to run on purpose, never for a test or an agent.
