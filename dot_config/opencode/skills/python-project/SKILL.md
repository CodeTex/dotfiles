---
name: python-project
description: Set up or understand Python project structure with uv, pytest, and ruff
---

## What I Do

Guide setup and configuration of Python projects following these conventions:

- **Package manager**: uv (never pip directly)
- **Testing**: pytest with `tests/unit/`, `tests/integration/`, `tests/e2e/` structure
- **Linting/Formatting**: ruff
- **Docstrings**: Google style
- **Config**: All in `pyproject.toml`

## Project Structure

```
project/
├── pyproject.toml
├── src/
│   └── package_name/
│       ├── __init__.py
│       └── ...
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/
│   └── adr/          # Architecture Decision Records
└── README.md
```

## pyproject.toml Essentials

```toml
[project]
name = "package-name"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "ruff>=0.4",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --tb=short"

[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP"]
```

## Common Commands

```bash
uv sync                    # Install dependencies
uv add <package>           # Add dependency
uv add --dev <package>     # Add dev dependency
uv run pytest              # Run tests
uv run ruff check .        # Lint
uv run ruff format .       # Format
```

## When to Use Me

- Setting up a new Python project
- Understanding existing project structure
- Configuring pytest, ruff, or pyproject.toml
- Questions about Python project conventions
