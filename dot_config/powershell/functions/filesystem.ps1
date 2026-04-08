# ============================================
# FILESYSTEM FUNCTIONS
# ============================================

function New-File {
    <#
    .SYNOPSIS
        Create a new empty file
    .DESCRIPTION
        Creates a new file in current directory, similar to Unix touch command
    .PARAMETER Name
        Name of file to create
    .EXAMPLE
        New-File test.txt
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Verbose "Creating new file '$Name'"
    New-Item -ItemType File -Name $Name -Path $PWD | Out-Null
}

function Get-CommandDefinition {
    <#
    .SYNOPSIS
        Show command source path and definition
    .DESCRIPTION
        Displays where a command is located and its definition
    .PARAMETER Name
        Command name to look up
    .EXAMPLE
        Get-CommandDefinition git
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    Write-Verbose "Showing definition of '$Name'"
    Get-Command $Name | Select-Object -ExpandProperty Definition
}

function Reset-PowerShellProfile {
    <#
    .SYNOPSIS
        Reload PowerShell profile to apply changes
    .DESCRIPTION
        Reloads profile configuration files without restarting PowerShell
    .EXAMPLE
        Reset-PowerShellProfile
    #>
    . $PROFILE
    . "$HOME\.config\powershell\profile.ps1"
    Write-Host "Profile reloaded successfully!" -ForegroundColor Green
}

function Copy-FileContentToClipboard {
    <#
    .SYNOPSIS
        Copy file contents to clipboard
    .DESCRIPTION
        Reads file content and copies text to clipboard
    .PARAMETER Path
        Path to file
    .EXAMPLE
        Copy-FileContentToClipboard config.json
    #>
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[string]$Path
	)
	Get-Content $Path -Raw | Set-Clipboard
	Write-Host "✓ Content of '$Path' copied to clipboard" -ForegroundColor Green
}

function Copy-ItemToClipboard {
    <#
    .SYNOPSIS
        Copy files or directories to clipboard
    .DESCRIPTION
        Copies file/directory objects to clipboard for pasting in file explorer
    .PARAMETER Path
        Paths to copy
    .EXAMPLE
        Copy-ItemToClipboard file.txt
    .EXAMPLE
        Copy-ItemToClipboard file1.txt, file2.txt, folder1
    #>
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

function Remove-Pycache {
    <#
    .SYNOPSIS
        Remove all __pycache__ directories
    .DESCRIPTION
        Recursively finds and removes all __pycache__ directories under the specified path
    .PARAMETER Path
        Root path to search (default: current directory)
    .EXAMPLE
        Remove-Pycache
    .EXAMPLE
        Remove-Pycache -Path C:\projects\myproj
    .EXAMPLE
        Remove-Pycache -Path . -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter(Position=0)]
        [string]$Path = '.'
    )

    Get-ChildItem -Path $Path -Directory -Force -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq '__pycache__' } |
        ForEach-Object {
            $target = $_.FullName
            if ($PSCmdlet.ShouldProcess($target, 'Remove directory')) {
                Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction SilentlyContinue
                Write-Output $target
            }
        }
}

function Remove-PycFiles {
    <#
    .SYNOPSIS
        Remove all .pyc files
    .DESCRIPTION
        Recursively finds and removes all .pyc compiled Python files under the specified path
    .PARAMETER Path
        Root path to search (default: current directory)
    .EXAMPLE
        Remove-PycFiles
    .EXAMPLE
        Remove-PycFiles -Path C:\projects\myproj
    .EXAMPLE
        Remove-PycFiles -Path . -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter(Position=0)]
        [string]$Path = '.'
    )

    Get-ChildItem -Path $Path -File -Filter '*.pyc' -Force -Recurse -ErrorAction SilentlyContinue |
        ForEach-Object {
            $target = $_.FullName
            if ($PSCmdlet.ShouldProcess($target, 'Remove file')) {
                Remove-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
                Write-Output $target
            }
        }
}

function Remove-PyArtifacts {
    <#
    .SYNOPSIS
        Remove all Python artifacts (__pycache__ directories and .pyc files)
    .DESCRIPTION
        Recursively removes all __pycache__ directories and .pyc files under the specified path
    .PARAMETER Path
        Root path to search (default: current directory)
    .PARAMETER SkipPycache
        Skip removal of __pycache__ directories
    .PARAMETER SkipPycFiles
        Skip removal of .pyc files
    .EXAMPLE
        Remove-PyArtifacts
    .EXAMPLE
        Remove-PyArtifacts -Path C:\projects\myproj
    .EXAMPLE
        Remove-PyArtifacts -Path . -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter(Position=0)]
        [string]$Path = '.',
        [switch]$SkipPycache,
        [switch]$SkipPycFiles
    )

    if (-not $SkipPycache) {
        Remove-Pycache -Path $Path -Confirm:$false
    }

    if (-not $SkipPycFiles) {
        Remove-PycFiles -Path $Path -Confirm:$false
    }
}
