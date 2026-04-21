# Technical Domain

Purpose: personal default conventions for Python-first repositories when project-local context does not override them.

Primary stack defaults:
- packaging and environment management: `uv`
- build backend: `uv_build`
- formatting and linting: `ruff format`, `ruff check`
- type checking: `ty`
- pre-commit workflow: `prek` with `.pre-commit-config.yml`
- docstrings: Google style

Execution defaults:
- prefer project-local `.venv` execution for Python tools
- on Windows prefer `.venv\Scripts\python`
- on Unix prefer `.venv/bin/python`
- if no `.venv` exists and a tool is ephemeral, use `uvx <tool> ...`
- avoid system `python` for project-local workflows

Testing defaults:
- use pytest when it pays off, not for trivial scripts or notebooks
- prefer behavior-focused tests over implementation-heavy tests
- bias toward integration tests when they cover the real risk better
- when using pytest, prefer `pytest-sugar` and `pytest-cov`

Code style defaults:
- simple over clever
- explicit over implicit
- functions and modules over classes unless state and behavior belong together
- avoid premature abstraction

Codebase references:
- `AGENTS.md`
- `skills/python-execution/SKILL.md`
- `skills/python-quality-gates/SKILL.md`
- `skills/prek-workflow/SKILL.md`
- `commands/quality.md`
- `commands/prek.md`
- `agents/python-engineer.md`
