---
name: debug-python
description: Systematic approach to debugging Python issues
---

## What I Do

Guide systematic debugging of Python code issues.

## Debugging Approach

1. **Reproduce**: Can you trigger the issue reliably?
2. **Isolate**: What's the minimal code that exhibits the problem?
3. **Hypothesize**: What could cause this behavior?
4. **Test**: Verify or refute the hypothesis
5. **Fix**: Address root cause, not symptoms

## Quick Diagnostics

```python
# Print debugging (simple but effective)
print(f"{variable=}")  # Python 3.8+ shows name and value

# Type checking at runtime
print(f"{type(variable)=}")

# Check what you actually have
print(f"{dir(obj)=}")
print(f"{vars(obj)=}")
```

## Common Issues & Checks

### Import Errors
```bash
uv run python -c "import module_name"  # Test import
uv pip list | grep package-name        # Check installed
```

### Type Mismatches
```python
# Often: None where value expected
assert value is not None, f"Expected value, got {value}"

# Or: string where int expected
print(f"{type(value)=}, {value=}")
```

### Async Issues
- Missing `await`
- Mixing sync/async incorrectly
- Event loop already running

### Path Issues
```python
from pathlib import Path
print(f"{Path.cwd()=}")
print(f"{Path(__file__).parent=}")
```

## Using pdb

```python
# Insert breakpoint
breakpoint()  # Python 3.7+

# Or
import pdb; pdb.set_trace()
```

**pdb commands:**
- `n` - next line
- `s` - step into
- `c` - continue
- `p expr` - print expression
- `l` - list source
- `q` - quit

## Using Rich for Better Output

```bash
uv add --dev rich
```

```python
from rich import print
from rich.traceback import install
install(show_locals=True)  # Enhanced tracebacks
```

## When to Use Me

- Tracking down bugs
- Understanding error messages
- Setting up debugging tools
- Systematic problem isolation
