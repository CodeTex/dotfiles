---
description: Create or refresh lightweight project-local context files that capture repo conventions and Python workflow patterns
agent: build
subtask: true
---

Create or refresh project-local context in the current repository.

Goals:
- Prefer project-local `.opencode/context/` over global defaults.
- Start by discovering relevant repo files and context with `@context-scout` when useful.
- Inspect the repository before asking questions.
- Ask only targeted questions the repo cannot answer safely.
- Create or update concise files only when needed:
  - `.opencode/context/navigation.md`
  - `.opencode/context/project-intelligence/navigation.md`
  - `.opencode/context/project-intelligence/technical-domain.md`
  - `.opencode/context/project-intelligence/decisions-log.md`
- Keep each file short, factual, and easy to scan.
- Capture stack, execution rules, testing style, quality gates, naming conventions, and durable workflow decisions.

If `$ARGUMENTS` is provided, treat it as extra context or scope:

$ARGUMENTS
