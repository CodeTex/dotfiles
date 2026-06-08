# ============================================
# UTILITY PROMPT INIT
# ============================================

function Get-ToolExecutable
{
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $commands = @(Get-Command $Name -CommandType Application -All -ErrorAction SilentlyContinue)
    if (-not $commands -or $commands.Count -eq 0)
    {
        return $null
    }

    $preferred = $commands |
        Where-Object { $_.Source -notmatch '[\\/]scoop[\\/]shims[\\/]' } |
        Select-Object -First 1

    if (-not $preferred)
    {
        $preferred = $commands | Select-Object -First 1
    }

    return [string]([System.IO.Path]::GetFullPath($preferred.Source))
}

function Get-InitCacheSignature
{
    param(
        [Parameter(Mandatory)]
        [string]$ToolName,

        [Parameter(Mandatory)]
        [string]$ExecutablePath,

        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [string]$TransformId = "none"
    )

    $exeItem = Get-Item -LiteralPath $ExecutablePath

    return @(
        "tool=$ToolName"
        "path=$ExecutablePath"
        "mtime=$($exeItem.LastWriteTimeUtc.Ticks)"
        "args=$($Arguments -join "`0")"
        "pwsh=$($PSVersionTable.PSVersion)"
        "transform=$TransformId"
    ) -join ";"
}

function Get-CachedInitContent
{
    param(
        [Parameter(Mandatory)]
        [string]$CachePath
    )

    if (-not (Test-Path -LiteralPath $CachePath))
    {
        return $null
    }

    return [System.IO.File]::ReadAllText($CachePath)
}

function Test-InitCacheFresh
{
    param(
        [Parameter(Mandatory)]
        [string]$CachePath,

        [Parameter(Mandatory)]
        [string]$Signature
    )

    if (-not (Test-Path -LiteralPath $CachePath))
    {
        return $false
    }

    $lines = Get-Content -LiteralPath $CachePath -TotalCount 5 -ErrorAction SilentlyContinue
    if (-not $lines)
    {
        return $false
    }

    $signatureLine = $lines | Where-Object { $_ -like '# signature: *' } | Select-Object -First 1
    if (-not $signatureLine)
    {
        return $false
    }

    return $signatureLine -eq "# signature: $Signature"
}

function Update-InitScriptCache
{
    param(
        [Parameter(Mandatory)]
        [string]$ToolName,

        [Parameter(Mandatory)]
        [string]$ExecutablePath,

        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [string]$CachePath,

        [scriptblock]$TransformScript = { param($s) $s },

        [string]$TransformId = "none"
    )

    $signature = Get-InitCacheSignature `
        -ToolName $ToolName `
        -ExecutablePath $ExecutablePath `
        -Arguments $Arguments `
        -TransformId $TransformId

    # Write-Host "[cache] tool=$ToolName" -ForegroundColor Cyan
    # Write-Host "[cache] signature=$signature" -ForegroundColor DarkGray
    # Write-Host "[cache] path=$CachePath" -ForegroundColor DarkGray

    # if (Test-InitCacheFresh -CachePath $CachePath -Signature $signature)
    # {
    #     Write-Host "[cache] HIT" -ForegroundColor Green
    #     return
    # }

    # Write-Host "[cache] MISS -> regenerating" -ForegroundColor Yellow

    if (Test-InitCacheFresh -CachePath $CachePath -Signature $signature)
    {
        return
    }

    $cacheDirectory = Split-Path -Parent $CachePath
    if (-not (Test-Path -LiteralPath $cacheDirectory))
    {
        New-Item -ItemType Directory -Path $cacheDirectory -Force | Out-Null
    }

    $initScript = & $ExecutablePath @Arguments | Out-String
    if ([string]::IsNullOrWhiteSpace($initScript))
    {
        return
    }

    $initScript = & $TransformScript $initScript

    $content = @(
        "# tool: $ToolName"
        "# signature: $signature"
        "# generated: $([DateTime]::UtcNow.ToString("o"))"
        $initScript.TrimStart()
    ) -join [Environment]::NewLine

    [System.IO.File]::WriteAllText($CachePath, $content, [System.Text.Encoding]::UTF8)
}

function Invoke-CachedShellTool
{
    param(
        [Parameter(Mandatory)]
        [string]$ToolName,

        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [string]$CachePath,

        [scriptblock]$TransformScript = { param($s) $s },

        [string]$TransformId = "none",

        [string]$InstallHint = ""
    )

    $executablePath = Get-ToolExecutable -Name $ToolName
    if (-not $executablePath)
    {
        if ($InstallHint)
        {
            Write-Warning "$ToolName not found. $InstallHint"
        } else
        {
            Write-Warning "$ToolName not found."
        }
        return
    }

    Update-InitScriptCache `
        -ToolName $ToolName `
        -ExecutablePath $executablePath `
        -Arguments $Arguments `
        -CachePath $CachePath `
        -TransformScript $TransformScript `
        -TransformId $TransformId

    if (Test-Path -LiteralPath $CachePath)
    {
        . $CachePath
    }
}
