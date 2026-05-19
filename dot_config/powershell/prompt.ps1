# ============================================
# PROMPT INITIALIZATION
# ============================================

# Custom update check
# Test-PowerShellUpdate

# Starship
function Get-StarshipExecutable {
    $starshipCommand = Get-Command starship -CommandType Application -ErrorAction SilentlyContinue
    if (-not $starshipCommand) {
        return $null
    }

    $starshipPath = $starshipCommand.Source
    $shimDirectory = Split-Path -Parent $starshipPath
    $scoopRoot = Split-Path -Parent $shimDirectory
    $scoopCurrentPath = Join-Path $scoopRoot "apps\starship\current\starship.exe"

    if ($starshipPath -match '\\scoop\\shims\\starship\.exe$' -and (Test-Path -LiteralPath $scoopCurrentPath)) {
        return $scoopCurrentPath
    }

    return $starshipPath
}

function Update-StarshipInitCache {
    param(
        [Parameter(Mandatory)]
        [string]$StarshipExecutable,

        [Parameter(Mandatory)]
        [string]$CachePath
    )

    $cacheExists = Test-Path -LiteralPath $CachePath
    $starshipItem = Get-Item -LiteralPath $StarshipExecutable
    $cachedInit = $null

    if ($cacheExists) {
        $cacheItem = Get-Item -LiteralPath $CachePath
        $cachedInit = [System.IO.File]::ReadAllText($CachePath)
        $cacheIsFresh = $cacheItem.LastWriteTimeUtc -ge $starshipItem.LastWriteTimeUtc
        $cacheUsesExecutable = $cachedInit.Contains($StarshipExecutable)

        if ($cacheIsFresh -and $cacheUsesExecutable) {
            return
        }
    }

    $cacheDirectory = Split-Path -Parent $CachePath
    if (-not (Test-Path -LiteralPath $cacheDirectory)) {
        New-Item -ItemType Directory -Path $cacheDirectory -Force | Out-Null
    }

    $initScript = & $StarshipExecutable init powershell --print-full-init | Out-String
    if (-not [string]::IsNullOrWhiteSpace($initScript)) {
        $starshipCommand = Get-Command starship -CommandType Application -ErrorAction SilentlyContinue
        if ($starshipCommand) {
            $resolvedCommandPath = $starshipCommand.Source
            if ($resolvedCommandPath -ne $StarshipExecutable) {
                $initScript = $initScript.Replace($resolvedCommandPath, $StarshipExecutable)
            }
        }

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

function Invoke-Starship-PreCommand {
    $defaultConfig = "$HOME\.config\starship\starship.toml"
    $dotfilesConfig = "$HOME\.config\starship\_starship.toml"

    if (-not (Test-Path -LiteralPath $dotfilesConfig)) {
        $ENV:STARSHIP_CONFIG = $defaultConfig
        return
    }

    $location = Get-Location
    if ($location.Provider.Name -ne "FileSystem") {
        $ENV:STARSHIP_CONFIG = $defaultConfig
        return
    }

    $dotfilesRoot = [System.IO.Path]::GetFullPath("$HOME\.config")
    $currentPath = [System.IO.Path]::GetFullPath($location.ProviderPath)
    $pathComparison = [System.StringComparison]::OrdinalIgnoreCase

    if ($currentPath.Equals($dotfilesRoot, $pathComparison) -or $currentPath.StartsWith("$dotfilesRoot\\", $pathComparison)) {
        $ENV:STARSHIP_CONFIG = $dotfilesConfig
        return
    }

    $ENV:STARSHIP_CONFIG = $defaultConfig
}

$starshipExecutable = Get-StarshipExecutable
if ($starshipExecutable) {
    $starshipCachePath = "$HOME\.cache\starship\init-powershell.ps1"

    try {
        Update-StarshipInitCache -StarshipExecutable $starshipExecutable -CachePath $starshipCachePath
    } catch {
        Write-Warning "Failed to refresh Starship init cache: $_"
    }

    if (Test-Path -LiteralPath $starshipCachePath) {
        . $starshipCachePath
    } else {
        Invoke-Expression (& $starshipExecutable init powershell)
    }
} else {
    Write-Warning "Starship not found. Install with: winget install starship"
}

# Oh My Posh
# if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
#     oh-my-posh init pwsh --config ~\.config\oh-my-posh\themes\spaceship.omp.json | Invoke-Expression
# } else {
#     Write-Warning "Oh-My-Posh not found. Install with: winget install oh-my-posh"
# }

# Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
} else {
    Write-Warning "Zoxide not found. Install with: winget install zoxide"
}

# Fastfetch (optional startup display)
# Uncomment if you want fastfetch on startup
# if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
#     fastfetch
# }
