---
name: python-execution
description: Run project-local Python tools via `.venv` when present, otherwise use `uvx` for ephemeral tools
---

## Rules

- Prefer the project interpreter inside `.venv` for project-local execution.
- On Windows, prefer `.venv\Scripts\python`.
- On Unix, prefer `.venv/bin/python`.
- If no `.venv` exists and you only need a tool temporarily, use `uvx <tool> ...`.
- Avoid system `python` for project execution when a local environment should be used.
- Always prefer `.venv` execution over bare tool commands when `.venv` exists.

## Typical patterns

```bash
.venv\Scripts\python -m pytest
.venv\Scripts\python -m ruff check .
.venv\Scripts\python -m ty check
```

```bash
uvx ruff check .
uvx ty check
uvx pytest -q
```

## Notes

- If the repo already standardizes on `uv run ...`, that is also acceptable when it clearly targets the local project environment.
- Still prefer `.venv`-scoped execution first when it is straightforward and available.
- Use the narrowest relevant command rather than full-suite checks by default.
