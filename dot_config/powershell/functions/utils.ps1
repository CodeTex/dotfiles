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

function Measure-ProfileLoad
{
    [CmdletBinding()]
    param(
        [string]$ProfileRoot = "$HOME\.config\powershell",
        [switch]$IncludeFunctionFiles
    )

    $results = [System.Collections.Generic.List[object]]::new()

    function Add-ProfileTiming
    {
        param(
            [string]$Name,
            [scriptblock]$Script
        )

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        & $Script
        $sw.Stop()

        $results.Add([pscustomobject]@{
            Name = $Name
            Milliseconds = $sw.ElapsedMilliseconds
        })
    }

    $environmentPath = Join-Path $ProfileRoot 'environment.ps1'
    $aliasesPath     = Join-Path $ProfileRoot 'aliases.ps1'
    $promptPath      = Join-Path $ProfileRoot 'prompt.ps1'
    $functionsPath   = Join-Path $ProfileRoot 'functions'

    if (Test-Path -LiteralPath $environmentPath)
    {
        Add-ProfileTiming -Name 'environment.ps1' -Script { . $environmentPath }
    }

    if (Test-Path -LiteralPath $functionsPath)
    {
        if ($IncludeFunctionFiles)
        {
            Get-ChildItem -LiteralPath $functionsPath -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
                $file = $_
                Add-ProfileTiming -Name "functions/$($file.Name)" -Script { . $file.FullName }
            }
        } else
        {
            Add-ProfileTiming -Name 'functions (all)' -Script {
                Get-ChildItem -LiteralPath $functionsPath -Filter '*.ps1' | ForEach-Object {
                    . $_.FullName
                }
            }
        }
    }

    if (Test-Path -LiteralPath $aliasesPath)
    {
        Add-ProfileTiming -Name 'aliases.ps1' -Script { . $aliasesPath }
    }

    if (Test-Path -LiteralPath $promptPath)
    {
        Add-ProfileTiming -Name 'prompt.ps1' -Script { . $promptPath }
    }

    $results |
        Sort-Object Milliseconds -Descending |
        Format-Table -AutoSize
}
