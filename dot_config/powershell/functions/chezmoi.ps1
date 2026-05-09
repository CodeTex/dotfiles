# ============================================
# CHEZMOI FUNCTIONS
# ============================================

function Invoke-ChezmoiPush {
    <#
    .SYNOPSIS
        Re-add dotfiles, commit, and push chezmoi source changes.
    .PARAMETER Message
        Commit message to use for the generated git commit.
    .EXAMPLE
        Invoke-ChezmoiPush
    .EXAMPLE
        Invoke-ChezmoiPush -Message "chore: tweak fish aliases"
    #>
    param(
        [string]$Message = "feat: update dotfiles"
    )

    chezmoi re-add
    if ($LASTEXITCODE -ne 0) {
        return
    }

    $pending = chezmoi git status -- --porcelain
    if ($LASTEXITCODE -ne 0) {
        return
    }

    if ([string]::IsNullOrWhiteSpace(($pending -join "`n"))) {
        Write-Host "Invoke-ChezmoiPush: no source changes to commit"
        return
    }

    chezmoi git add -- -A
    if ($LASTEXITCODE -ne 0) {
        return
    }

    chezmoi git commit -- -m $Message
    if ($LASTEXITCODE -ne 0) {
        return
    }

    chezmoi git push
}
