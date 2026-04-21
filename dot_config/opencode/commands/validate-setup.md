---
description: Validate the custom OpenCode setup, referenced files, and local context wiring without modifying anything
agent: plan
subtask: true
---

Validate the current OpenCode customization setup in read-only mode.

Check for:
- referenced global config files under `~/.config/opencode/`
- agents, commands, skills, and context files that are missing or stale
- mismatches between command targets and available agents
- missing `navigation.md` files in context directories when deeper files exist
- local `.opencode/context/` files in the current repo, if present

Return:
- `Errors`
- `Warnings`
- `Suggested fixes`

Do not modify files.
