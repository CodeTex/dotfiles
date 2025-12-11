# ============================================
# ENVIRONMENT VARIABLES
# ============================================

$ENV:EDITOR = "vim"

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

# Locale (for LazyVim)
$ENV:LANG = "$((Get-Culture).Name).UTF-8"

# Custom update notification (choose one option above)
# $ENV:POWERSHELL_UPDATECHECK = 'Off'
# NOTE: the above envar had to be set manually in the user's environment variables for it to work
