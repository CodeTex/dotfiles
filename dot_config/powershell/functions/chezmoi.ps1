# ============================================
# CHEZMOI FUNCTIONS
# ============================================

# Lazy-load Chezmoi home directory
function Get-ChezmoiHome {
    if (-not $script:ChezmoiHome) {
        $script:ChezmoiHome = chezmoi source-path
    }
    return $script:ChezmoiHome
}

function Show-ChezmoiStatus {
    <#
    .SYNOPSIS
        Display Git status of chezmoi source directory
    .EXAMPLE
        Show-ChezmoiStatus
    #>
    Push-Location (Get-ChezmoiHome)
    git status
    Pop-Location
}

function Update-ChezmoiFiles {
    <#
    .SYNOPSIS
        Re-add modified files to chezmoi
    .EXAMPLE
        Update-ChezmoiFiles ~/.vimrc
    #>
    chezmoi re-add @args
}

function Sync-ChezmoiFromRemote {
    <#
    .SYNOPSIS
        Pull latest changes from remote and apply to system
    .DESCRIPTION
        Pulls latest changes from Git remote and applies them using chezmoi
    .EXAMPLE
        Sync-ChezmoiFromRemote
    #>
    Push-Location (Get-ChezmoiHome)
    git pull
    Pop-Location
    chezmoi apply
}

function Show-ChezmoiChanges {
    <#
    .SYNOPSIS
        Pull latest changes and show diff without applying
    .DESCRIPTION
        Pulls latest changes from Git remote and displays differences
    .EXAMPLE
        Show-ChezmoiChanges
    #>
    Push-Location (Get-ChezmoiHome)
    git pull
    Pop-Location
    chezmoi diff
}

function Publish-ChezmoiChanges {
    <#
    .SYNOPSIS
        Commit and push chezmoi changes to remote
    .DESCRIPTION
        Re-adds modified files, commits with message, and pushes to remote
    .PARAMETER Message
        Commit message
    .EXAMPLE
        Publish-ChezmoiChanges
    .EXAMPLE
        Publish-ChezmoiChanges -Message "Update vim config"
    #>
    param(
        [string]$Message = "feat: update dotfiles"
    )
    
    chezmoi re-add
    Push-Location (Get-ChezmoiHome)
    git add .
    git commit -m $Message
    git push
    Pop-Location
}

function Edit-ChezmoiFile {
    <#
    .SYNOPSIS
        Edit chezmoi-managed file and apply changes
    .DESCRIPTION
        Opens file in editor and automatically applies changes after editing
    .EXAMPLE
        Edit-ChezmoiFile ~/.vimrc
    #>
    chezmoi edit --apply @args
}
