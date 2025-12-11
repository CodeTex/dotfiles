# ============================================
# UTILITY FUNCTIONS
# ============================================

function note {
    <#
    .SYNOPSIS
        Quick note taking with nvim.
    .EXAMPLE
        note daily/2024-01-15.md
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$FileName
    )

    $NotesDir = "$HOME\Notes"
    if (-not (Test-Path -Path $NotesDir)) {
        New-Item -Path $NotesDir -ItemType Directory | Out-Null
    }

    $FilePath = Join-Path -Path $NotesDir -ChildPath $FileName
    $DirectoryPath = Split-Path -Path $FilePath -Parent

    if (-not (Test-Path -Path $DirectoryPath)) {
        New-Item -Path $DirectoryPath -ItemType Directory | Out-Null
    }

    if (-not (Test-Path -Path $FilePath)) {
        New-Item -Path $FilePath -ItemType File | Out-Null
    }

    Push-Location -Path $NotesDir
    nvim $FilePath
    Pop-Location
}

function Test-PowerShellUpdate {
    <#
    .SYNOPSIS
        Check for PowerShell updates and display minimal notification.
    .DESCRIPTION
        Runs asynchronously in background. Shows custom symbol + version if update available.
        Only checks once per session.
    .EXAMPLE
        Test-PowerShellUpdate
    #>
    [CmdletBinding()]
    param()

    # Only check once per session
    if ($Global:UpdateCheckDone) {
        return
    }
    $Global:UpdateCheckDone = $true
    
    Start-Job -ScriptBlock {
        try {
            $current = $PSVersionTable.PSVersion
            $latest = (Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest' -TimeoutSec 2).tag_name.TrimStart('v')
            
            if ([version]$latest -gt [version]$current) {
                return $latest
            }
        } catch {
            # Silently fail if offline or timeout
        }
    } | Receive-Job -Wait -AutoRemoveJob | ForEach-Object {
        # Customize this line with your preferred style
        Write-Host "󰁔 󰚰 $($_)" -ForegroundColor Yellow
    }
}
