# ============================================
# VIRTUALENV / PYTHON ENVIRONMENT HELPERS
# ============================================

function Activate-VirtualEnvironment {
    <#
    .SYNOPSIS
        Activate a project's Python virtual environment in the current session
    .DESCRIPTION
        Dot-sources a virtualenv activation script so that environment changes
        (PATH, environment variables, prompt changes) apply to the current
        interactive session.
    .PARAMETER Path
        Path to the activation script. Defaults to .\.venv\Scripts\Activate.ps1
    .EXAMPLE
        Activate-VirtualEnvironment
    .EXAMPLE
        Activate-VirtualEnvironment .\env\Scripts\Activate.ps1
    #>
    [CmdletBinding()]
    param(
        [string]$Path = ".\.venv\Scripts\Activate.ps1"
    )

    if (Test-Path -Path $Path) {
        # Dot-source so the activation affects the current session
        . $Path
    }
    else {
        Write-Host "No virtualenv activation script found at '$Path'" -ForegroundColor Yellow
    }
}
