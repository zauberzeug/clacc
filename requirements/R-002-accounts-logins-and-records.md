---
type: concept
tags: [accounts]
status: active
---

# Accounts, logins and records

clacc uses these words, in the code and in everything written about it.

- **Account:** a Claude account, which clacc recognizes by its account id (`accountUuid`).
- **Name:** the label a person gives an account in clacc (R-004).
- **Login** (the code says `token`): what Claude Code keeps after a sign-in, with the access token and the refresh token that keep a session signed in.
  A login can also hold the sign-ins to MCP servers, and those move with it.
- **Record** (`oauthAccount`): the email, organisation and ids of an account, which Claude Code keeps in its `.claude.json`.
- **Claude Code's folder:** `~/.claude`, or the folder that `CLAUDE_CONFIG_DIR` names (R-020).
- **Active login:** the login in Claude Code's folder, on which its sessions run.
- **Stored account:** an account with a record in the store (R-003).
- **Parked token:** the login of a stored account that is not active, waiting in the store.
- **Run folder:** the config folder of `clacc run` sessions on one account, with a login of its own (R-015).
