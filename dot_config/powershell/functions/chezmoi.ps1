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

# Preview remote vs local changes and potential conflicts without modifying working tree
function Check-ChezmoiRemoteLocal {
    <#
    .SYNOPSIS
        Preview commits and file changes on remote and local for chezmoi source.
    .DESCRIPTION
        Fetches remote refs, optionally runs `chezmoi re-add` to capture local
        modifications into the source, and then shows commits/changed files on
        both sides. It also lists files changed on both branches (likely
        conflict candidates) and prints a three-way merge preview using
        `git merge-tree` so you can visually inspect conflicts before pulling
        or pushing.
    .PARAMETER ReaddBefore
        If supplied, runs `chezmoi re-add` before inspecting diffs to ensure
        local modifications are present in the source tree.
    .PARAMETER Upstream
        Optional upstream ref to compare against (eg. 'origin/main'). If not
        provided the function attempts to read the configured upstream for
        the current branch.
    .EXAMPLE
        Check-ChezmoiRemoteLocal
    .EXAMPLE
        Check-ChezmoiRemoteLocal -ReaddBefore -Upstream 'origin/main'
    #>
    param(
        [switch]$ReaddBefore,
        [string]$Upstream
    )

    $chezHome = Get-ChezmoiHome
    if (-not $chezHome) {
        Write-Error "Could not determine chezmoi source path. Ensure 'chezmoi' is installed and configured."
        return
    }

    Push-Location $chezHome
    try {
        git fetch --all --prune

        if (-not $Upstream) {
            $Upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
        }
        if (-not $Upstream) {
            Write-Warning "No upstream found for current branch; falling back to 'origin/main'."
            $Upstream = 'origin/main'
        }

        if ($ReaddBefore) {
            Write-Host "Running: chezmoi re-add (will update chezmoi source)" -ForegroundColor Yellow
            chezmoi re-add
        }

        $base = git merge-base HEAD $Upstream 2>$null
        if (-not $base) {
            Write-Warning "Could not determine merge-base between HEAD and $Upstream. Aborting preview."
            return
        }

        Write-Host "`n=== Commits on remote not local (HEAD..$Upstream) ===" -ForegroundColor Cyan
        # Quote commit ranges to avoid PowerShell interpreting ".." as the range operator
        git --no-pager log --oneline "HEAD..$Upstream"

        Write-Host "`n=== Commits local not on remote ($Upstream..HEAD) ===" -ForegroundColor Cyan
        git --no-pager log --oneline "$Upstream..HEAD"

        Write-Host "`n=== Files modified locally (since merge-base) ===" -ForegroundColor Cyan
        git --no-pager diff --name-status "$base..HEAD"

        Write-Host "`n=== Files modified on remote (since merge-base) ===" -ForegroundColor Cyan
        git --no-pager diff --name-status "$base..$Upstream"

        Write-Host "`n=== Potential conflict candidates (changed on both) ===" -ForegroundColor Cyan
        # Quote ranges to prevent PowerShell from parsing ".." as its range operator
        $local = git diff --name-only "$base..HEAD"
        $remote = git diff --name-only "$base..$Upstream"
        if ($local -and $remote) {
            $conflicts = @()
            foreach ($f in $local) { if ($remote -contains $f) { $conflicts += $f } }
            if ($conflicts.Count -gt 0) { $conflicts | ForEach-Object { Write-Host $_ } } else { Write-Host "No overlapping file changes detected." }
        } else {
            Write-Host "No changes detected on one side to compare." 
        }

        Write-Host "`n=== Three-way merge preview (conflict markers shown) ===" -ForegroundColor Cyan
        git merge-tree $base HEAD $Upstream | Out-Host
    }
    finally {
        Pop-Location
    }
}

function Show-ChezmoiCommandHelp {
    Write-Host "Chezmoi command wrapper"
    Write-Host "Usage: cm <command> [args]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  gs, status              Show chezmoi source git status"
    Write-Host "  diff                    Pull remote and show chezmoi diff"
    Write-Host "  re-add [path ...]       Re-add files into chezmoi source"
    Write-Host "  edit <path ...>         Edit a chezmoi-managed file and apply"
    Write-Host "  pull                    Pull chezmoi source and apply"
    Write-Host "  push [message]          Re-add, commit, and push"
    Write-Host "  check [--readd] [--upstream <ref>]"
    Write-Host "                          Preview local/remote divergence"
    Write-Host "  help                    Show this help"
}

function Invoke-ChezmoiCommand {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    if (-not $Arguments -or $Arguments.Count -eq 0) {
        Show-ChezmoiCommandHelp
        return
    }

    $command = $Arguments[0].ToLowerInvariant()
    $rest = @()
    if ($Arguments.Count -gt 1) {
        $rest = $Arguments[1..($Arguments.Count - 1)]
    }

    switch ($command) {
        'help' { Show-ChezmoiCommandHelp; return }
        '--help' { Show-ChezmoiCommandHelp; return }
        '-h' { Show-ChezmoiCommandHelp; return }
        'list' { Show-ChezmoiCommandHelp; return }

        'gs' { Show-ChezmoiStatus; return }
        'status' { Show-ChezmoiStatus; return }

        'diff' { Show-ChezmoiChanges; return }

        're-add' { Update-ChezmoiFiles @rest; return }
        'readd' { Update-ChezmoiFiles @rest; return }
        'ra' { Update-ChezmoiFiles @rest; return }

        'edit' {
            if ($rest.Count -eq 0) {
                Write-Error "Usage: cm edit <path ...>"
                return
            }
            Edit-ChezmoiFile @rest
            return
        }

        'pull' { Sync-ChezmoiFromRemote; return }

        'push' {
            if ($rest.Count -eq 0) {
                Publish-ChezmoiChanges
                return
            }

            $message = $null
            if (($rest[0] -eq '-m' -or $rest[0] -eq '--message') -and $rest.Count -gt 1) {
                $message = ($rest[1..($rest.Count - 1)] -join ' ')
            }
            else {
                $message = ($rest -join ' ')
            }

            if ([string]::IsNullOrWhiteSpace($message)) {
                Publish-ChezmoiChanges
            }
            else {
                Publish-ChezmoiChanges -Message $message
            }
            return
        }

        'check' {
            $readdBefore = $false
            $upstream = $null

            for ($i = 0; $i -lt $rest.Count; $i++) {
                $token = $rest[$i]

                if ($token -in @('--readd', '-readd', 'readd')) {
                    $readdBefore = $true
                    continue
                }

                if ($token -eq '--upstream') {
                    if ($i + 1 -ge $rest.Count) {
                        Write-Error "Missing value for --upstream"
                        return
                    }
                    $upstream = $rest[$i + 1]
                    $i++
                    continue
                }

                if ($token.StartsWith('--upstream=')) {
                    $upstream = $token.Substring('--upstream='.Length)
                    continue
                }

                Write-Warning "Ignoring unknown check argument: $token"
            }

            if ($upstream) {
                Check-ChezmoiRemoteLocal -ReaddBefore:$readdBefore -Upstream $upstream
            }
            else {
                Check-ChezmoiRemoteLocal -ReaddBefore:$readdBefore
            }
            return
        }

        default {
            Write-Error "Unknown chezmoi command: $command"
            Show-ChezmoiCommandHelp
        }
    }
}
