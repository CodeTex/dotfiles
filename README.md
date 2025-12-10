# chezmoi — personal dotfiles

This repository contains my personal configuration managed with [chezmoi](https://www.chezmoi.io/).  
It stores user-level configuration files and settings that I sync across my machines. No sensitive data is included.

**Currently includes:** Linux (Arch/Fedora) configs  
**Planned:** Windows configs (WSL and native)

## Daily Commands

- `chezmoi add <path>` — Start tracking a file or directory
- `chezmoi edit <file>` — Edit a source file (opens `$EDITOR`)
- `chezmoi apply` — Apply changes from source to home directory
- `chezmoi diff` — Show what would change
- `chezmoi status` — Preview what `apply` would do
- `chezmoi update` — Update your chezmoi state
- `chezmoi cd` — Open shell in the chezmoi source directory
- `chezmoi forget <file>` — Stop tracking a file

## Key Concepts

**Templates** — Use `{{ }}` syntax in files for dynamic values (e.g., hostname-specific settings). Variables are defined in `.chezmoidata.yaml`.

**Source vs. Deploy** — chezmoi maintains a *source* directory separate from your home directory. `apply` syncs them.

**Conditional Files** — Use `.chezmoiignore` to skip files based on OS or other patterns.

## Setup

```bash
chezmoi init <repo-url>
chezmoi apply
```

## Documentation

Full command reference and advanced features (hooks, scripts, etc.):  
https://www.chezmoi.io/user-guide/command-overview/
