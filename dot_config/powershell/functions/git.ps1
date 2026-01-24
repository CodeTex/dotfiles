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
