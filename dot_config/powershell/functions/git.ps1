# ============================================
# GIT FUNCTIONS
# ============================================

function Invoke-GitClone {
    <#
    .SYNOPSIS
        Clone a Git repository to local machine
    .EXAMPLE
        Invoke-GitClone https://github.com/user/repo
    #>
    git clone $args
}

function Show-GitStatus {
    <#
    .SYNOPSIS
        Display Git repository status in short format
    .EXAMPLE
        Show-GitStatus
    #>
    git status -sb $args
}

function Show-GitTree {
    <#
    .SYNOPSIS
        Display Git commit history as tree
    .EXAMPLE
        Show-GitTree
    #>
    git log --graph --oneline --decorate $args
}

function Remove-PrunedBranches {
    <#
    .SYNOPSIS
        Remove local branches with gone remote tracking
    .DESCRIPTION
        Removes local branches whose remote tracking branches no longer exist
    .EXAMPLE
        Remove-PrunedBranches
    #>
    git branch --list --format "%(if:equals=[gone])%(upstream:track)%(then)%(refname:short)%(end)" |
        Where-Object { $_ -ne "" } |
        ForEach-Object { git branch -d $_ }
}

function Clear-GitBranches {
    <#
    .SYNOPSIS
        Clean up local branches without valid remote tracking
    .DESCRIPTION
        Interactive cleanup of branches with gone remotes or no remote tracking
    .PARAMETER Force
        Skip confirmation prompt
    .EXAMPLE
        Clear-GitBranches
    .EXAMPLE
        Clear-GitBranches -Force
    #>
    [CmdletBinding()]
    param (
        [switch]$Force
    )

    # Check if current directory is a git repository
    if (-not (Test-Path -Path ".git" -PathType Container)) {
        Write-Error "Current directory is not a git repository."
        return
    }
    
    # Fetch and prune
    git fetch --prune

    # Get all branches with [gone] remote tracking
    $branchesWithGoneRemote = git branch --list --format "%(if:equals=[gone])%(upstream:track)%(then)%(refname:short)%(end)" | 
        Where-Object { $_ -ne "" }

    # Get all local branches without any remote tracking
    $branchesWithoutRemote = git branch --list --format "%(if)%(upstream)%(then)%(else)%(refname:short)%(end)" | 
        Where-Object { $_ -ne "" }

    # Combine both lists
    $branchesToDelete = @($branchesWithGoneRemote) + @($branchesWithoutRemote) | Sort-Object -Unique

    # Get branches with valid remotes for display
    $allBranches = git branch --list --format "%(refname:short)"
    $branchesWithRemote = $allBranches | Where-Object { $branchesToDelete -notcontains $_ }

    # Display results
    Write-Host "Local branches with valid remote tracking:" -ForegroundColor Green
    if ($branchesWithRemote.Count -eq 0) {
        Write-Host "  None found"
    } else {
        $branchesWithRemote | ForEach-Object { Write-Host "  $($_)" }
    }
    
    Write-Host "`nLocal branches with gone or no remote tracking:" -ForegroundColor Yellow
    if ($branchesToDelete.Count -eq 0) {
        Write-Host "  None found"
    } else {
        $branchesToDelete | ForEach-Object { Write-Host "  $($_)" }
        
        # Ask to delete branches without remotes
        if (-not $Force) {
            $confirmation = Read-Host "`nDo you want to delete all local branches without valid remote tracking? (y/N)"
            if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
                Write-Host "Operation cancelled." -ForegroundColor Cyan
                return
            }
        }
        
        # Delete branches without valid remotes
        foreach ($branch in $branchesToDelete) {
            # Skip the current branch
            $currentBranch = git rev-parse --abbrev-ref HEAD
            if ($branch -eq $currentBranch) {
                Write-Host "Skipping current branch: $branch" -ForegroundColor Magenta
                continue
            }
            
            Write-Host "Deleting branch: $branch" -ForegroundColor Yellow
            git branch -D $branch
        }
        
        Write-Host "`nCleanup complete!" -ForegroundColor Green
    }
}

function Get-GitHubContent {
    <#
    .SYNOPSIS
        Download files from GitHub repository
    .DESCRIPTION
        Downloads files from a GitHub repository URL using GitHub API
    .PARAMETER Url
        GitHub repository URL
    .PARAMETER OutputPath
        Local directory to save files
    .PARAMETER Token
        GitHub personal access token for private repositories
    .EXAMPLE
        Get-GitHubContent https://github.com/user/repo/tree/main/path
    .EXAMPLE
        Get-GitHubContent https://github.com/user/repo/tree/main/path C:\Downloads
    #>
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Url,
        
        [Parameter(Position = 1)]
        [string]$OutputPath = (Get-Location).Path,
        
        [Parameter(Position = 2)]
        [string]$Token
    )
    
    begin {
        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }
        
        # Parse the GitHub URL
        if ($Url -match 'github\.com/([^/]+)/([^/]+)/(tree|blob)/[^/]+/(.+)') {
            $User = $matches[1]
            $Repository = $matches[2] -replace '\.git$', ''
            $Path = $matches[4]
        }
        elseif ($Url -match 'github\.com/([^/]+)/([^/]+)/?$') {
            # Root of repository
            $User = $matches[1]
            $Repository = $matches[2] -replace '\.git$', ''
            $Path = ""
        }
        else {
            throw "Invalid GitHub URL format. Expected: https://github.com/user/repo/tree/branch/path"
        }
        
        $baseUrl = "https://api.github.com/repos/$User/$Repository/contents/$Path"
        
        $headers = @{
            'Accept' = 'application/vnd.github.v3+json'
        }
        if ($Token) {
            $headers['Authorization'] = "token $Token"
        }
    }
    
    process {
        try {
            Write-Host "Fetching content from: $baseUrl" -ForegroundColor Cyan
            
            $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers
            
            $files = @()
            if ($response -is [Array]) {
                $files = $response | Where-Object { $_.type -eq "file" }
            } else {
                if ($response.type -eq "file") {
                    $files = @($response)
                }
            }
            
            foreach ($file in $files) {
                $outputFile = Join-Path $OutputPath $file.name
                Write-Host "Downloading: $($file.name) -> $outputFile" -ForegroundColor Green
                
                Invoke-WebRequest -Uri $file.download_url -OutFile $outputFile -Headers $headers
            }
            
            Write-Host "Download completed! Files saved to: $OutputPath" -ForegroundColor Green
        }
        catch {
            Write-Error "An error occurred: $_"
        }
    }
}


function Get-GitRepoAge {
    <#
    .SYNOPSIS
        List files and directories in a git repository older than a threshold.
    .DESCRIPTION
        Scans a repository directory and returns items older than the specified
        number of days. By default it checks top-level entries. Use -Recursive
        to search subdirectories. The -Depth parameter limits recursion levels
        (0 means unlimited).
    .PARAMETER RepoPath
        Path to the repository (defaults to current directory).
    .PARAMETER Days
        Age threshold in days (defaults to 360).
    .PARAMETER Recursive
        If specified, search recursively.
    .PARAMETER Depth
        Maximum recursion depth when -Recursive is used. 0 = unlimited.
    .EXAMPLE
        Get-GitRepoAge -RepoPath "C:\path\to\repo"
    .EXAMPLE
        Get-GitRepoAge -RepoPath "C:\path\to\repo" -Days 90 -Recursive -Depth 2
    .EXAMPLE
        # Current directory, recursive, 60 days old, exportable to CSV
        Get-GitRepoAge -Days 60 -Recursive -PassThru | Export-Csv results.csv -NoTypeInformation
    #>
    [CmdletBinding()]
    param(
        [string]$RepoPath = ".",
        [Alias('DaysThreshold')]
        [int]$Days = 360,
        [switch]$Recursive,
        [int]$Depth = 0,
        [switch]$PassThru
    )

    try {
        $repoRoot = (Resolve-Path -LiteralPath $RepoPath -ErrorAction Stop).Path
    }
    catch {
        Write-Error "Invalid path: $RepoPath"
        return
    }

    $isGitRepo = git -C "$repoRoot" rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $isGitRepo -ne 'true') {
        Write-Error "Path is not a git repository: $repoRoot"
        return
    }

    $thresholdDate = (Get-Date).AddDays(-$Days)

    if ($Recursive) {
        if ($Depth -gt 0) {
            $items = Get-ChildItem -LiteralPath $repoRoot -Force -Recurse -Depth $Depth -ErrorAction SilentlyContinue
        }
        else {
            $items = Get-ChildItem -LiteralPath $repoRoot -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    else {
        $items = Get-ChildItem -LiteralPath $repoRoot -Force -ErrorAction SilentlyContinue
    }

    $now = Get-Date
    $results = foreach ($item in $items) {
        if ($item.Name -eq '.git') { continue }
        if ($item.FullName -like "$repoRoot\.git*") { continue }

        $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $item.FullName)
        $relativePath = $relativePath -replace '\\', '/'
        if ([string]::IsNullOrWhiteSpace($relativePath) -or $relativePath -eq '.') { continue }

        $gitLog = git -C "$repoRoot" log -1 --format=%aI%n%an -- "$relativePath" 2>$null
        if (-not $gitLog -or $gitLog.Count -lt 2) { continue }

        try {
            $commitDate = [DateTime]::Parse($gitLog[0])
        }
        catch {
            continue
        }

        if ($commitDate -ge $thresholdDate) { continue }

        [PSCustomObject]@{
            Name           = if ($Recursive) { $relativePath } else { $item.Name }
            Type           = if ($item.PSIsContainer) { 'Directory' } else { 'File' }
            LastCommitDate = $commitDate
            Author         = $gitLog[1]
            DaysOld        = [math]::Round((($now) - $commitDate).TotalDays)
        }
    }

    if (-not $results -or $results.Count -eq 0) {
        Write-Host "No items older than $Days days in $repoRoot" -ForegroundColor Yellow
        if (-not $Recursive) {
            Write-Host "Tip: use -Recursive to scan subdirectories" -ForegroundColor DarkGray
        }
        return
    }

    $results = $results | Sort-Object LastCommitDate

    if ($PassThru) {
        $results
        return
    }

    $results | Format-Table Name, Type, LastCommitDate, Author, DaysOld -AutoSize
}

function Invoke-GitHelper {
    <#
    .SYNOPSIS
        Unified dispatcher for git helper utilities
    .DESCRIPTION
        Groups git maintenance and inspection commands: clean, prune, age
    .PARAMETER Command
        Subcommand to execute: clean, prune, age, help
    .EXAMPLE
        gg clean
    .EXAMPLE
        gg prune
    .EXAMPLE
        gg age -Recursive -DaysThreshold 60
    .EXAMPLE
        gg help
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet('clean', 'prune', 'age', 'help')]
        [string]$Command,

        [switch]$Force,
        [Parameter(Position = 1)]
        [string]$RepoPath,
        [Alias('DaysThreshold')]
        [int]$Days = 360,
        [switch]$Recursive,
        [int]$Depth = 0,
        [switch]$PassThru
    )

    switch ($Command) {
        'clean' {
            Clear-GitBranches -Force:$Force
        }
        'prune' {
            Remove-PrunedBranches
        }
        'age' {
            $params = @{}
            if ($PSBoundParameters.ContainsKey('RepoPath')) { $params['RepoPath'] = $RepoPath }
            if ($PSBoundParameters.ContainsKey('Days')) { $params['Days'] = $Days }
            elseif ($PSBoundParameters.ContainsKey('DaysThreshold')) { $params['Days'] = $Days }
            if ($PSBoundParameters.ContainsKey('Recursive')) { $params['Recursive'] = $Recursive }
            if ($PSBoundParameters.ContainsKey('Depth')) { $params['Depth'] = $Depth }
            if ($PSBoundParameters.ContainsKey('PassThru')) { $params['PassThru'] = $PassThru }

            Get-GitRepoAge @params
        }
        'help' {
            Write-Host "Git utilities dispatcher" -ForegroundColor Cyan
            Write-Host "Usage: gg <command> [args]" -ForegroundColor White
            Write-Host ""
            Write-Host "Commands:" -ForegroundColor Cyan
            Write-Host "  clean                  Clean up local branches without valid remote tracking"
            Write-Host "  prune                  Remove local branches with gone remote tracking"
            Write-Host "  age [options]          List files/directories older than threshold"
            Write-Host "  help                   Show this help message"
            Write-Host ""
            Write-Host "Examples:" -ForegroundColor Cyan
            Write-Host "  gg clean -Force"
            Write-Host "  gg prune"
            Write-Host "  gg age -Recursive -Days 60"
            Write-Host "  gg age -RepoPath . -Days 90 -PassThru | Export-Csv results.csv"
        }
    }
}
