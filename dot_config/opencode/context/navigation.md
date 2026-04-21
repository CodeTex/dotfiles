# Context Navigation

Purpose: entrypoint for the lightweight context tree used by custom agents and commands.

Search order:
- project-local `.opencode/context/`
- global `~/.config/opencode/context/`

Quick routes:
- personal Python defaults -> `project-intelligence/technical-domain.md`
- durable decisions -> `project-intelligence/decisions-log.md`
- context usage rules -> `core/navigation.md`

Rules:
- prefer local context over global when both exist
- start with navigation files, then read only the smallest relevant file
- treat global context as fallback defaults, not project truth
