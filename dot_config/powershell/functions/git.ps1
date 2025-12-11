# ============================================
# GIT FUNCTIONS
# ============================================

function Get-GitClone {
    <#
    .SYNOPSIS
        Git clone wrapper. Alias: gcl
    #>
    git clone $args
}

function Get-GitStatus {
    <#
    .SYNOPSIS
        Git status short format. Alias: gs
    #>
    git status -sb $args
}

function Get-GitTree {
    <#
    .SYNOPSIS
        Git log tree view. Alias: gt
    #>
    git log --graph --oneline --decorate $args
}

function Get-RemovePrunedBranches {
    <#
    .SYNOPSIS
        Remove local branches with gone remotes. Alias: gprune
    #>
    git branch --list --format "%(if:equals=[gone])%(upstream:track)%(then)%(refname:short)%(end)" |
        Where-Object { $_ -ne "" } |
        ForEach-Object { git branch -d $_ }
}

function Clean-GitBranches {
    <#
    .SYNOPSIS
        Clean up local branches without valid remote tracking.
    .PARAMETER Force
        Skip confirmation prompt.
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
        Download files from GitHub repository. Alias: ghc
    .EXAMPLE
        ghc https://github.com/username/repo-name/tree/main/path/to/folder
        ghc https://github.com/username/repo-name/tree/main/path/to/folder C:\Downloads
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
        # Expected format: https://github.com/user/repo/tree/branch/path/to/folder
        # or: https://github.com/user/repo/blob/branch/path/to/file
        
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
        
        $headers = @()
        if ($Token) {
            $headers += "-H", "Authorization: token $Token"
        }
    }
    
    process {
        try {
            Write-Host "Fetching content from: $baseUrl" -ForegroundColor Cyan
            
            $response = if ($Token) {
                curl.exe -s $headers $baseUrl | ConvertFrom-Json
            } else {
                curl.exe -s $baseUrl | ConvertFrom-Json
            }
            
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
                
                if ($Token) {
                    curl.exe -s -L $headers -o $outputFile $file.download_url
                } else {
                    curl.exe -s -L -o $outputFile $file.download_url
                }
            }
            
            Write-Host "Download completed! Files saved to: $OutputPath" -ForegroundColor Green
        }
        catch {
            Write-Error "An error occurred: $_"
        }
    }
}