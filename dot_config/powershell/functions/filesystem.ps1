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

function Copy-FileContent {
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[string]$Path
	)
	Get-Content $Path -Raw | Set-Clipboard
	Write-Host "✓ Content of '$Path' copied to clipboard" -ForegroundColor Green
}

function Copy-ItemToClipboard {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Path
    )

    $items = @()
    foreach ($p in $Path) {
        $resolvedPath = Resolve-Path $p -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            $items += $resolvedPath.Path
        } else {
            Write-Warning "Path not found: $p"
        }
    }

    if ($items.Count -gt 0) {
		$fileObjects = Get-Item -Path $items
        Set-Clipboard -Value $fileObjects
        Write-Host "✓ $($items.Count) item(s) copied to clipboard (ready to paste)" -ForegroundColor Green
    }
}
