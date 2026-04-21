# Decisions Log

Purpose: durable defaults and trade-offs that should survive across sessions.

- 2026-04-20: Prefer a lean agent set over a large persona catalog. Rationale: lower context cost and clearer delegation.
- 2026-04-20: Keep built-in `build` and `plan` as the main primary agents. Rationale: stable defaults with custom subagents layered on top.
- 2026-04-20: Standardize Python workflows on `uv`, `uv_build`, `ruff`, `ty`, `pytest`, and `prek`. Rationale: one consistent toolchain beats mixed habits.
- 2026-04-20: Prefer `.venv` execution first and `uvx` only as fallback for ephemeral tools. Rationale: deterministic project-local behavior.
- 2026-04-20: Prefer short prompts plus skills and small context files over large agent manifests. Rationale: less context bloat and easier maintenance.
