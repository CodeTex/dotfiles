---
description: Run pytest using project configuration (pyproject.toml or pytest.ini) and package from local .venv. Abort if no .venv, not a Python project, or pytest unavailable. OS-agnostic (Linux, macOS, Windows).
agent: plan
model: github-copilot/gpt-4.1
---

# Test Command - Python Project Only

Checks:
1. Ensure a .venv exists in project root (detects virtual environments on Linux, macOS, or Windows).
2. Ensure this is a Python project (pyproject.toml or pytest.ini present).
3. Confirm pytest is installed in the .venv.
4. Run pytest using detected config and user arguments. OS-aware activation: 
   - Unix: `source .venv/bin/activate && pytest $ARGS`
   - Windows: `.venv\\Scripts\\activate && pytest $ARGS`
5. Abort with a clear error message if any check fails.

$ARGUMENTS

# Execution
If all checks pass, properly activate the venv and run pytest for the current OS. If any check fails, clearly indicate reason (missing .venv, not a Python project, pytest not installed).

# Contextual Reaction
If user calls `/test unit`, `/test integration`, or `/test e2e`:
- Acknowledge which test type is being run (e.g. "Running unit tests with pytest...")
- For unknown argument, react with generic "Running selected pytest tests..."
