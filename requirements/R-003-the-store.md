---
type: data-format
tags: [store]
status: active
---

# The store

clacc keeps what it knows in one folder: `~/.clacc`, or the folder that `CLACC_HOME` names.
Everything in it is readable by the user only.

| Path                      | Holds                                                                                     |
| ------------------------- | ----------------------------------------------------------------------------------------- |
| `<name>.account.json`     | the record of a stored account; this file is what makes `<name>` a stored account         |
| `<name>.credentials.json` | the parked token; on macOS this path only names a Keychain item (R-021)                   |
| `<name>.local/`           | the run folder of `<name>` (R-015)                                                        |
| `login.XXXXXX/`           | the temporary login folder of an `add` or a reading, removed when that ends (R-013, R-031) |
| `.lent.lock`              | held while a parked token is lent out for a reading (R-031)                               |

A store from an earlier version of clacc keeps working, because people update clacc with their accounts in place.
For example, a run folder whose `settings.json` is still a link to the shared file gets a file of its own at its next start (R-019).
