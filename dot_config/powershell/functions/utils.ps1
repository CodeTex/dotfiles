# ============================================
# UTILITY FUNCTIONS
# ============================================

function New-Note {
    <#
    .SYNOPSIS
        Create and edit note file with nvim
    .DESCRIPTION
        Creates directory structure and note file if needed, then opens in nvim
    .PARAMETER FileName
        Note file name or path relative to Notes directory
    .EXAMPLE
        New-Note daily.md
    .EXAMPLE
        New-Note journal/2024-01-15.md
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
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        nvim $FilePath
    } else {
        Write-Error "nvim not found. Install with: scoop install neovim"
        return
    }
    Pop-Location
}

function Test-PowerShellUpdate {
    <#
    .SYNOPSIS
        Check for PowerShell updates asynchronously
    .DESCRIPTION
        Checks GitHub for latest PowerShell release and displays notification if update available.
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
        Write-Host "󰁔 󰚰 $($_)" -ForegroundColor Yellow
    }
}
