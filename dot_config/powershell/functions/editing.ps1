# ============================================
# EDITOR FUNCTIONS
# ============================================

function Edit-PowerShellProfile {
    <#
    .SYNOPSIS
        Open PowerShell profile in default editor
    .EXAMPLE
        Edit-PowerShellProfile
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\profile.ps1"
}

function Edit-PowerShellAliases {
    <#
    .SYNOPSIS
        Open PowerShell aliases configuration in default editor
    .EXAMPLE
        Edit-PowerShellAliases
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\aliases.ps1"
}

function Edit-PowerShellEnvironment {
    <#
    .SYNOPSIS
        Open PowerShell environment variables configuration in default editor
    .EXAMPLE
        Edit-PowerShellEnvironment
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\environment.ps1"
}

function Edit-PowerShellPrompt {
    <#
    .SYNOPSIS
        Open PowerShell prompt configuration in default editor
    .EXAMPLE
        Edit-PowerShellPrompt
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\prompt.ps1"
}

function Edit-PowerShellFunctions {
    <#
    .SYNOPSIS
        Open PowerShell functions directory in default editor
    .EXAMPLE
        Edit-PowerShellFunctions
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\functions"
}

function Edit-VimConfig {
    <#
    .SYNOPSIS
        Open Vim configuration in default editor
    .EXAMPLE
        Edit-VimConfig
    #>
    & $ENV:EDITOR "$ENV:USERPROFILE\.config\vim\.vimrc"
}

function Edit-WeztermConfig {
    <#
    .SYNOPSIS
        Open WezTerm configuration in default editor
    .EXAMPLE
        Edit-WeztermConfig
    #>
    & $ENV:EDITOR "$ENV:USERPROFILE\.config\wezterm\wezterm.lua"
}
