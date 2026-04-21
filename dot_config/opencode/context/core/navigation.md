# Core Context

Purpose: shared rules for using the context tree without bloating prompt space.

Quick routes:
- how to load context -> `../navigation.md`
- Python defaults -> `../project-intelligence/technical-domain.md`
- durable defaults and trade-offs -> `../project-intelligence/decisions-log.md`

Loading rules:
- begin with the nearest `navigation.md`
- prefer project-local `.opencode/context/` files over global files
- use global context only as fallback or personal default guidance
- keep reads narrow and task-driven

When to consult context:
- before multi-file edits
- before changing Python tooling, testing, packaging, or pre-commit behavior
- before architecture or workflow decisions that may already be documented
