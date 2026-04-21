---
name: prek-workflow
description: Run prek from the local `.venv` when available and prefer `.pre-commit-config.yml` over `prek.toml`
---

## Rules

- Prefer `.pre-commit-config.yml` over `prek.toml`.
- When a project `.venv` exists, prefer running `prek` from that environment.
- On Windows, prefer `.venv\Scripts\prek`.
- On Unix, prefer `.venv/bin/prek`.
- If no `.venv` exists and you need `prek` ephemerally, use `uvx prek ...`.
- Avoid using a system-installed `prek` when a project-local environment should own the workflow.

## Typical patterns

```bash
.venv\Scripts\prek run --all-files
.venv\Scripts\prek run ruff --files path\to\file.py
```

```bash
uvx prek run --all-files
```

## Notes

- Use targeted hook runs when the task only touches a small area.
- Use `--all-files` when validating broader repository-wide formatting or policy changes.
