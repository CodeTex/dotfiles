---
name: git-workflow
description: Git workflow patterns including commits, branches, and PR conventions
---

## What I Do

Provide guidance on git workflows. I do NOT execute git commands that modify remote state without explicit user request.

## Commit Messages

Use conventional commits when the project uses them, otherwise keep it simple:

```
<type>: <short description>

[optional body explaining why, not what]
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Keep the subject line under 72 characters. Body wraps at 72.

## Branch Naming

```
<type>/<short-description>

Examples:
feat/user-authentication
fix/memory-leak-in-parser
refactor/extract-validation-module
```

## Before Committing

1. `git status` - Review what's staged
2. `git diff --staged` - Verify the actual changes
3. Check for secrets, credentials, `.env` files
4. Ensure tests pass if making code changes

## PR Workflow

1. Create feature branch from main/develop
2. Make focused commits (one logical change per commit)
3. Push branch, create PR
4. PR description should explain the "why"

## Safety Rules

**Never without explicit request:**
- `git push --force`
- `git reset --hard`
- `git clean -fd`
- Push to main/master directly
- Amend commits that have been pushed

**Always safe:**
- `git status`, `git log`, `git diff`
- `git branch`, `git stash`
- Creating local commits

## When to Use Me

- Questions about git workflow
- Crafting commit messages
- Understanding branch strategies
- PR best practices
