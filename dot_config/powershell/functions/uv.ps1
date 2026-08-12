# ============================================
# UV (Python Package Manager) FUNCTIONS
# ============================================

function Add-UvScriptDependency {
    <#
    .SYNOPSIS
        Add dependency to UV inline script metadata
    .DESCRIPTION
        Adds package dependencies to a Python script's inline metadata block
    .PARAMETER ScriptPath
        Path to Python script file
    .PARAMETER Packages
        Package names to add as dependencies
    .EXAMPLE
        Add-UvScriptDependency script.py requests pandas
    #>
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ScriptPath,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Packages
    )

    uv add --script $ScriptPath @Packages
}

function Invoke-UvScript {
    <#
    .SYNOPSIS
        Run Python script using UV
    .DESCRIPTION
        Executes Python script with UV, managing dependencies automatically
    .PARAMETER ScriptPath
        Path to Python script file
    .PARAMETER Arguments
        Arguments to pass to the script
    .EXAMPLE
        Invoke-UvScript script.py
    .EXAMPLE
        Invoke-UvScript script.py --arg value
    #>
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ScriptPath,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    uv run --script $ScriptPath @Arguments
}

function Compare-Deps {
    <#
    .SYNOPSIS
        Compare uv export dependencies with SW360 project releases.
    .DESCRIPTION
        Exports dependencies from a uv project, fetches releases assigned to an SW360
        project, applies optional name mappings, and prints mismatches/missing entries.
    .PARAMETER ProjectId
        SW360 project identifier.
    .PARAMETER Path
        Path to the uv project root. Defaults to current directory.
    .PARAMETER Prune
        Optional list of package names to pass as repeated --prune arguments to uv export.
    .PARAMETER MapFile
        Path to JSON object mapping uv package names to SW360 release names.
    .PARAMETER Sw360BaseUrl
        SW360 API base URL.
    .EXAMPLE
        Compare-Deps -ProjectId 67d73a757e6a46b6929e38fbf06ee96a
    .EXAMPLE
        Compare-Deps -ProjectId 67d73a757e6a46b6929e38fbf06ee96a -Prune cb-info
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ProjectId,

        [string]$Path = (Get-Location).Path,

        [string[]]$Prune,

        [string]$MapFile = (Join-Path $HOME '.config/powershell/deps-name-map.json'),

        [string]$Sw360BaseUrl = 'https://sw360.siemens.com/resource/api'
    )

    function Get-CanonicalName {
        param([Parameter(Mandatory)][string]$Name)
        return (($Name.Trim().ToLowerInvariant()) -replace '[\._-]+', '-')
    }

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Error 'uv command not found in PATH.'
        return
    }

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Error 'curl.exe command not found in PATH.'
        return
    }

    if (-not $env:SW360_API_KEY) {
        Write-Error 'SW360_API_KEY is not set.'
        return
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Write-Error "Project path not found: $Path"
        return
    }

    $mapping = @{}
    if (Test-Path -LiteralPath $MapFile) {
        try {
            $rawMap = Get-Content -LiteralPath $MapFile -Raw | ConvertFrom-Json -AsHashtable
            foreach ($entry in $rawMap.GetEnumerator()) {
                $mapping[(Get-CanonicalName -Name $entry.Key)] = [string]$entry.Value
            }
        } catch {
            Write-Error "Failed to read mapping file '$MapFile': $($_.Exception.Message)"
            return
        }
    } else {
        Write-Host "Mapping file not found, proceeding without mappings: $MapFile" -ForegroundColor Yellow
    }

    $uvDeps = @()
    Push-Location -LiteralPath $Path
    try {
        $uvArgs = @(
            'export',
            '--no-default-groups',
            '--frozen',
            '--format', 'requirements.txt',
            '--no-hashes',
            '--no-annotate'
        )

        foreach ($pr in @($Prune)) {
            if ($pr) {
                $uvArgs += @('--prune', $pr)
            }
        }

        $uvOutput = & uv @uvArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "uv export failed: $($uvOutput -join [Environment]::NewLine)"
            return
        }

        foreach ($line in $uvOutput) {
            $text = [string]$line
            if ([string]::IsNullOrWhiteSpace($text)) { continue }

            $trimmed = $text.Trim()
            if ($trimmed.StartsWith('#')) { continue }
            if ($trimmed -eq '-e .') { continue }

            $base = ($trimmed -split ';', 2)[0].Trim()
            if ($base -match '^([A-Za-z0-9._-]+)==(.+)$') {
                $name = $matches[1]
                $version = $matches[2].Trim()
                $uvDeps += [pscustomobject]@{
                    Name = $name
                    CanonicalName = Get-CanonicalName -Name $name
                    Version = $version
                }
            }
        }
    } finally {
        Pop-Location
    }

    if (-not $uvDeps -or $uvDeps.Count -eq 0) {
        Write-Error 'No dependencies parsed from uv export output.'
        return
    }

    $url = "$Sw360BaseUrl/projects/$ProjectId/releases?transitive=false"
    $curlArgs = @(
        '--silent',
        '--show-error',
        '--fail',
        '--request', 'GET',
        '--url', $url,
        '--header', "Authorization: Token $($env:SW360_API_KEY)",
        '--header', 'Content-Type: application/json'
    )

    $swOutput = & curl.exe @curlArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "SW360 request failed: $($swOutput -join [Environment]::NewLine)"
        return
    }

    try {
        $swJson = ($swOutput -join [Environment]::NewLine) | ConvertFrom-Json
    } catch {
        Write-Error "Failed to parse SW360 JSON response: $($_.Exception.Message)"
        return
    }

    $swReleases = @($swJson._embedded.'sw360:releases')
    if (-not $swReleases) { $swReleases = @() }

    $swByCanonical = @{}
    foreach ($release in $swReleases) {
        if (-not $release.name -or -not $release.version) { continue }

        $canonical = Get-CanonicalName -Name ([string]$release.name)
        if (-not $swByCanonical.ContainsKey($canonical)) {
            $swByCanonical[$canonical] = [System.Collections.Generic.List[object]]::new()
        }

        $swByCanonical[$canonical].Add([pscustomobject]@{
            Id = [string]$release.id
            Name = [string]$release.name
            Version = [string]$release.version
        })
    }

    $uvByCanonical = @{}
    foreach ($dep in $uvDeps) {
        if (-not $uvByCanonical.ContainsKey($dep.CanonicalName)) {
            $uvByCanonical[$dep.CanonicalName] = [System.Collections.Generic.List[object]]::new()
        }
        $uvByCanonical[$dep.CanonicalName].Add($dep)
    }

    $mismatches = [System.Collections.Generic.List[object]]::new()
    $missingInSw360 = [System.Collections.Generic.List[object]]::new()
    $matchedSwCanonical = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($uvCanonical in $uvByCanonical.Keys | Sort-Object) {
        $uvItems = @($uvByCanonical[$uvCanonical])
        $uvName = [string]$uvItems[0].Name
        $uvVersions = @($uvItems | Select-Object -ExpandProperty Version -Unique | Sort-Object)

        $expectedSwName = if ($mapping.ContainsKey($uvCanonical)) { [string]$mapping[$uvCanonical] } else { $uvName }
        $expectedSwCanonical = Get-CanonicalName -Name $expectedSwName

        $swItems = if ($swByCanonical.ContainsKey($expectedSwCanonical)) { @($swByCanonical[$expectedSwCanonical]) } else { @() }

        if ($swItems.Count -eq 0) {
            $missingInSw360.Add([pscustomobject]@{
                Package = $uvName
                UvVersion = ($uvVersions -join ',')
                ExpectedSw360Name = $expectedSwName
            })
            continue
        }

        $null = $matchedSwCanonical.Add($expectedSwCanonical)
        $swVersions = @($swItems | Select-Object -ExpandProperty Version -Unique | Sort-Object)

        $isSingleAndEqual = ($uvVersions.Count -eq 1 -and $swVersions.Count -eq 1 -and $uvVersions[0] -eq $swVersions[0])
        if (-not $isSingleAndEqual) {
            $mismatches.Add([pscustomobject]@{
                Package = $uvName
                UvVersion = ($uvVersions -join ',')
                Sw360Name = [string]$swItems[0].Name
                Sw360Versions = ($swVersions -join ',')
            })
        }
    }

    $missingInUv = [System.Collections.Generic.List[object]]::new()
    foreach ($swCanonical in $swByCanonical.Keys | Sort-Object) {
        if (-not $matchedSwCanonical.Contains($swCanonical)) {
            $swItems = @($swByCanonical[$swCanonical])
            $swVersions = @($swItems | Select-Object -ExpandProperty Version -Unique | Sort-Object)
            $missingInUv.Add([pscustomobject]@{
                Sw360Name = [string]$swItems[0].Name
                Sw360Versions = ($swVersions -join ',')
            })
        }
    }

    $totalUv = $uvByCanonical.Keys.Count
    $totalSw = $swByCanonical.Keys.Count
    $matchCount = $totalUv - $mismatches.Count - $missingInSw360.Count

    Write-Host "`nDependency comparison" -ForegroundColor Cyan
    Write-Host "  UV packages:      $totalUv"
    Write-Host "  SW360 packages:   $totalSw"
    Write-Host "  Matches:          $matchCount" -ForegroundColor Green
    Write-Host "  Mismatches:       $($mismatches.Count)" -ForegroundColor Yellow
    Write-Host "  Missing in SW360: $($missingInSw360.Count)" -ForegroundColor Yellow
    Write-Host "  Missing in UV:    $($missingInUv.Count)" -ForegroundColor Yellow

    if ($mismatches.Count -gt 0) {
        Write-Host "`nMismatches" -ForegroundColor Yellow
        foreach ($item in $mismatches | Sort-Object Package) {
            Write-Host ("  {0} {1} > {2}" -f $item.Package, $item.UvVersion, $item.Sw360Versions)
        }
    }

    if ($missingInSw360.Count -gt 0) {
        Write-Host "`nMissing in SW360" -ForegroundColor Yellow
        foreach ($item in $missingInSw360 | Sort-Object Package) {
            Write-Host ("  {0} {1} (expected SW360 name: {2})" -f $item.Package, $item.UvVersion, $item.ExpectedSw360Name)
        }
    }

    if ($missingInUv.Count -gt 0) {
        Write-Host "`nMissing in UV" -ForegroundColor Yellow
        foreach ($item in $missingInUv | Sort-Object Sw360Name) {
            Write-Host ("  {0} {1}" -f $item.Sw360Name, $item.Sw360Versions)
        }
    }

    if ($mismatches.Count -eq 0 -and $missingInSw360.Count -eq 0 -and $missingInUv.Count -eq 0) {
        Write-Host "`nAll dependencies are in sync." -ForegroundColor Green
    }
}
