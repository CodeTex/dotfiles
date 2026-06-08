# ============================================
# PROMPT INITIALIZATION
# ============================================

# Custom update check
# Test-PowerShellUpdate

# ============================================
# HELPERS
# ============================================

function Initialize-ShellTool
{
    param(
        [string]$Name,
        [string]$InitArgs = "powershell"
    )

    if (Get-Command $Name -ErrorAction SilentlyContinue)
    {
        Invoke-Expression (& { (& $Name $InitArgs.Split() | Out-String) })
    } else
    {
        Write-Warning "$Name not found. Install with: mise use -g $Name"
    }
}

# ============================================
# TOOL INITIALIZATION
# ============================================

Initialize-ShellTool "mise" "activate pwsh"
# Initialize-ShellTool "starship" "init powershell"
Initialize-ShellTool "zoxide" "init powershell"


# ============================================
# STARSHIP INITIALIZATION
# ============================================

# Starship
function Get-StarshipExecutable
{
    $starshipCommand = Get-Command starship -CommandType Application -ErrorAction SilentlyContinue
    if (-not $starshipCommand)
    {
        return $null
    }

    return $starshipCommand.Source
}

function Update-StarshipInitCache
{
    param(
        [Parameter(Mandatory)]
        [string]$StarshipExecutable,

        [Parameter(Mandatory)]
        [string]$CachePath
    )

    $cacheExists = Test-Path -LiteralPath $CachePath
    $starshipItem = Get-Item -LiteralPath $StarshipExecutable
    $cachedInit = $null

    if ($cacheExists)
    {
        $cacheItem = Get-Item -LiteralPath $CachePath
        $cachedInit = [System.IO.File]::ReadAllText($CachePath)
        $cacheIsFresh = $cacheItem.LastWriteTimeUtc -ge $starshipItem.LastWriteTimeUtc
        $cacheUsesExecutable = $cachedInit.Contains($StarshipExecutable)

        if ($cacheIsFresh -and $cacheUsesExecutable)
        {
            return
        }
    }

    $cacheDirectory = Split-Path -Parent $CachePath
    if (-not (Test-Path -LiteralPath $cacheDirectory))
    {
        New-Item -ItemType Directory -Path $cacheDirectory -Force | Out-Null
    }

    $initScript = & $StarshipExecutable init powershell --print-full-init | Out-String
    if (-not [string]::IsNullOrWhiteSpace($initScript))
    {
        $continuationPromptPattern = @'
(?ms)^    # Invoke Starship and set continuation prompt\r?\n.*?^    \)\r?\n
'@
        $continuationPromptReplacement = @'
    # Use a static continuation prompt to avoid an extra Starship process on startup.
    Set-PSReadLineOption -ContinuationPrompt '∙ '
'@
        $initScript = [Regex]::Replace($initScript, $continuationPromptPattern, $continuationPromptReplacement)

        [System.IO.File]::WriteAllText($CachePath, $initScript, [System.Text.Encoding]::UTF8)
    }
}

function Invoke-Starship-PreCommand
{
    $defaultConfig = "$HOME\.config\starship\starship.toml"
    $dotfilesConfig = "$HOME\.config\starship\_starship.toml"

    if (-not (Test-Path -LiteralPath $dotfilesConfig))
    {
        $ENV:STARSHIP_CONFIG = $defaultConfig
        return
    }

    $location = Get-Location
    if ($location.Provider.Name -ne "FileSystem")
    {
        $ENV:STARSHIP_CONFIG = $defaultConfig
        return
    }

    $dotfilesRoot = [System.IO.Path]::GetFullPath("$HOME\.config")
    $currentPath = [System.IO.Path]::GetFullPath($location.ProviderPath)
    $pathComparison = [System.StringComparison]::OrdinalIgnoreCase

    if ($currentPath.Equals($dotfilesRoot, $pathComparison) -or $currentPath.StartsWith("$dotfilesRoot\\", $pathComparison))
    {
        $ENV:STARSHIP_CONFIG = $dotfilesConfig
        return
    }

    $ENV:STARSHIP_CONFIG = $defaultConfig
}

$starshipExecutable = Get-StarshipExecutable
if ($starshipExecutable)
{
    $starshipCachePath = "$HOME\.cache\starship\init-powershell.ps1"

    try
    {
        Update-StarshipInitCache -StarshipExecutable $starshipExecutable -CachePath $starshipCachePath
    } catch
    {
        Write-Warning "Failed to refresh Starship init cache: $_"
    }

    if (Test-Path -LiteralPath $starshipCachePath)
    {
        . $starshipCachePath
    } else
    {
        Invoke-Expression (& $starshipExecutable init powershell)
    }
} else
{
    Write-Warning "Starship not found. Install with: mise use -g starship"
}
