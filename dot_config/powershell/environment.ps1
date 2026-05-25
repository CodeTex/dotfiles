# ============================================
# ENVIRONMENT VARIABLES
# ============================================

# General
$ENV:EDITOR = "vim"
# Use a portable UTF-8 locale for Git/Perl on Windows.
# Culture-based values like en-US.UTF-8 may not be recognized, causing locale warnings.
# C.UTF-8 avoids those warnings while keeping UTF-8 behavior.
$ENV:LANG = "C.UTF-8"
$ENV:LC_ALL = "C.UTF-8"

# PowerShell
$ENV:PWSH_HOME = "$HOME\.config\powershell"

# Vim
$ENV:MYVIMRC = "$HOME\.config\vim\.vimrc"

# Starship
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"

# Zoxide
$ENV:_ZO_DATA_DIR = "$HOME\.config"

# Bat
$ENV:BAT_CONFIG_DIR = "$HOME\.config\bat"

# FZF
$ENV:FZF_DEFAULT_OPTS = @'
--color=fg:-1,fg+:#ffffff,bg:-1,bg+:#3c4048
--color=hl:#5ea1ff,hl+:#5ef1ff,info:#ffbd5e,marker:#5eff6c
--color=prompt:#ff5ef1,spinner:#bd5eff,pointer:#ff5ea0,header:#5eff6c
--color=gutter:-1,border:#3c4048,scrollbar:#7b8496,label:#7b8496
--color=query:#ffffff
--border="rounded"
--border-label=""
--preview-window="border-rounded"
--height 40%
--preview="bat -n --color=always {}"
'@

# uv
$UV_CACHE_DIR = "$HOME\AppData\Local\uv\cache"
$UV_CACHE_ENV_DIR = "$UV_CACHE_DIR\environments-v2"

# Custom update notification (choose one option above)
# $ENV:POWERSHELL_UPDATECHECK = 'Off'
# NOTE: the above envar had to be set manually in the user's environment variables for it to work
