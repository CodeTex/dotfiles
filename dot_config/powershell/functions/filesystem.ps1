# ============================================
# FILESYSTEM FUNCTIONS
# ============================================

function New-File {
    <#
    .SYNOPSIS
        Create a new file. Alias: touch
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Verbose "Creating new file '$Name'"
    New-Item -ItemType File -Name $Name -Path $PWD | Out-Null
}

function Show-Command {
    <#
    .SYNOPSIS
        Show command definition. Alias: which
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    Write-Verbose "Showing definition of '$Name'"
    Get-Command $Name | Select-Object -ExpandProperty Definition
}

function Get-FontList {
    <#
    .SYNOPSIS
        List installed fonts. Alias: flist
    #>
    (New-Object System.Drawing.Text.InstalledFontCollection).Families
}

function Reload-Profile {
    <#
    .SYNOPSIS
    	Reloads the PowerShell profile to apply recent changes
    #>
    . $PROFILE
    . "$HOME\.config\powershell\profile.ps1"
    Write-Host "Profile reloaded successfully!" -ForegroundColor Green
}
