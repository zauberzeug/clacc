---
type: behavior
tags: [headroom, tokens, safety]
status: active
---

# A parked token is lent for a reading

A parked token lies outside any config folder, so clacc lends it a temporary config folder for a reading, under the lock `.lent.lock`.
Claude Code may renew an expired token there, which can retire the old refresh token (R-005).
So clacc lets Claude Code do the reading and never reads a token value to compare accounts.

The token comes back to its parked place however the reading ends, also when clacc is stopped right after a renewal.
It comes back with its other fields kept, readable by the user only and with one link.
The temporary folder and the lock go with it.

A switch takes the same lock first, so it waits until a reading is over (R-011).
