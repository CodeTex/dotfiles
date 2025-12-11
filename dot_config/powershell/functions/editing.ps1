# ============================================
# EDITOR FUNCTIONS
# ============================================

function Get-EditProfile {
    <#
    .SYNOPSIS
        Edit PowerShell profile. Alias: vp
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\profile.ps1"
}

function Get-EditProfileAliases {
    <#
    .SYNOPSIS
        Edit PowerShell profile aliases. Alias: vpa
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\aliases.ps1"
}

function Get-EditProfileEnv {
    <#
    .SYNOPSIS
        Edit PowerShell profile environment variables. Alias: vpe
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\environment.ps1"
}

function Get-EditProfilePrompt {
    <#
    .SYNOPSIS
        Edit PowerShell profile prompt configuration. Alias: vpp
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\prompt.ps1"
}

function Get-EditProfileFunctions {
    <#
    .SYNOPSIS
        Edit PowerShell profile functions. Alias: vpf
    #>
    & $ENV:EDITOR "$HOME\.config\powershell\functions"
}

function Get-EditVim {
    <#
    .SYNOPSIS
        Edit Vim config. Alias: vv
    #>
    & $ENV:EDITOR "$ENV:USERPROFILE\.config\vim\.vimrc"
}

function Get-EditWezterm {
    <#
    .SYNOPSIS
        Edit WezTerm config. Alias: vw
    #>
    & $ENV:EDITOR "$ENV:USERPROFILE\.config\wezterm\wezterm.lua"
}
