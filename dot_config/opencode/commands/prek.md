---
description: Run prek validation with project-local `.venv` preference and targeted hook selection
agent: python-engineer
subtask: true
---

Validate pre-commit hooks for this task.

- Load the Python execution skill and the prek workflow skill first.
- Prefer `.venv` execution when available.
- Prefer targeted hook runs before broader `--all-files` validation unless the change justifies it.
- Prefer `.pre-commit-config.yml` over `prek.toml` conventions.

$ARGUMENTS
