# ============================================
# PROMPT INITIALIZATION
# ============================================

$script:ConfigRoot = Split-Path -Parent $PSCommandPath
. "$ConfigRoot\functions\prompt-helpers.ps1"

# Invoke-CachedShellTool `
#     -ToolName "mise" `
#     -Arguments @("activate", "pwsh") `
#     -CachePath "$HOME\.cache\powershell\mise-activate-pwsh.ps1" `
#     -InstallHint "Install with: scoop install mise"

Invoke-CachedShellTool `
    -ToolName "zoxide" `
    -Arguments @("init", "powershell") `
    -CachePath "$HOME\.cache\powershell\zoxide-init-powershell.ps1" `
    -InstallHint "Install with: mise use -g zoxide"

Invoke-CachedShellTool `
    -ToolName "starship" `
    -Arguments @("init", "powershell", "--print-full-init") `
    -CachePath "$HOME\.cache\powershell\starship-init-powershell.ps1" `
    -InstallHint "Install with: mise use -g starship"

    