---
name: python-quality-gates
description: Apply pragmatic Python validation with ruff, ty, and pytest using the narrowest useful scope
---

## Default quality gate order

1. Formatting or formatting check when relevant
2. Linting with `ruff`
3. Type checking with `ty`
4. Tests with `pytest` only when the change justifies them

## Rules

- Prefer narrow checks over full-suite runs.
- Do not add or run pytest for trivial scripts or notebooks unless it clearly pays off.
- When pytest is relevant, prefer project conventions such as `pytest-sugar` and `pytest-cov`.
- If one fast check clearly fails, fix that before escalating to slower checks.

## Typical examples

```bash
uv run ruff format --check path/to/file.py
uv run ruff check path/to/file.py
uv run ty path/to/package
uv run pytest tests/integration/test_feature.py -q
```

Use full-repo checks only when the task or risk level justifies them.
