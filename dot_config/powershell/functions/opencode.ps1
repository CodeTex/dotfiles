# ============================================
# PROJECT REGISTRY MANAGEMENT
# ============================================

function Open-Project {
    <#
    .SYNOPSIS
        Opens a project folder with opencode using a registry of shortcuts.
    
    .DESCRIPTION
        Manages a registry of project shortcuts and opens them with opencode.
        Automatically tracks recently opened projects.
    
    .PARAMETER Name
        The project shortcut name to open.
    
    .PARAMETER Add
        Register the current directory (or specified path) with a shortcut name.
    
    .PARAMETER Path
        Used with -Add to specify a path other than current directory.
    
    .PARAMETER Remove
        Remove a project from the registry.
    
    .PARAMETER List
        List all registered projects.
    
    .PARAMETER Recent
        Show recently opened projects.
    
    .PARAMETER Edit
        Open the registry file in your default editor.
    
    .EXAMPLE
        Open-Project myapp
        Opens the project registered as "myapp"
    
    .EXAMPLE
        Open-Project -Add myapp
        Registers current directory as "myapp"
    
    .EXAMPLE
        Open-Project -Add website -Path C:\Dev\MySite
        Registers specified path as "website"
    
    .EXAMPLE
        Open-Project -List
        Shows all registered projects
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'Open')]
    param(
        [Parameter(ParameterSetName = 'Open', Position = 0)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $registryPath = Join-Path $HOME ".config/powershell/project-registry.json"
            if (Test-Path $registryPath) {
                $registry = Get-Content $registryPath | ConvertFrom-Json
                $registry.projects.PSObject.Properties.Name | Where-Object { $_ -like "$wordToComplete*" }
            }
        })]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'Add', Mandatory)]
        [string]$Add,
        
        [Parameter(ParameterSetName = 'Add')]
        [string]$Path,
        
        [Parameter(ParameterSetName = 'Remove', Mandatory)]
        [string]$Remove,
        
        [Parameter(ParameterSetName = 'List')]
        [switch]$List,
        
        [Parameter(ParameterSetName = 'Recent')]
        [switch]$Recent,
        
        [Parameter(ParameterSetName = 'Edit')]
        [switch]$Edit
    )
    
    # Registry file path
    $registryPath = Join-Path $HOME ".config/powershell/project-registry.json"
    
    # Initialize registry if it doesn't exist
    function Initialize-Registry {
        if (-not (Test-Path $registryPath)) {
            $initialRegistry = @{
                projects = @{}
                recent = @()
            } | ConvertTo-Json -Depth 10
            
            $registryDir = Split-Path $registryPath -Parent
            if (-not (Test-Path $registryDir)) {
                New-Item -ItemType Directory -Path $registryDir -Force | Out-Null
            }
            
            Set-Content -Path $registryPath -Value $initialRegistry
            Write-Host "✓ Created new project registry at: $registryPath" -ForegroundColor Green
        }
    }
    
    # Load registry
    function Get-Registry {
        Initialize-Registry
        Get-Content $registryPath | ConvertFrom-Json
    }
    
    # Save registry
    function Save-Registry {
        param($Registry)
        $Registry | ConvertTo-Json -Depth 10 | Set-Content $registryPath
    }
    
    # Add recent entry
    function Add-RecentEntry {
        param($Name, $Path)
        
        $registry = Get-Registry
        
        # Remove existing entry for this project if it exists
        $registry.recent = @($registry.recent | Where-Object { $_.name -ne $Name })
        
        # Add new entry at the beginning
        $newEntry = [PSCustomObject]@{
            name = $Name
            path = $Path
            lastOpened = (Get-Date).ToString("o")
        }
        
        $registry.recent = @($newEntry) + @($registry.recent)
        
        # Keep only last 10 recent entries
        if ($registry.recent.Count -gt 10) {
            $registry.recent = $registry.recent[0..9]
        }
        
        Save-Registry $registry
    }
    
    # Handle different parameter sets
    switch ($PSCmdlet.ParameterSetName) {
        'Add' {
            $targetPath = if ($Path) { 
                Resolve-Path $Path -ErrorAction Stop 
            } else { 
                Get-Location 
            }
            
            $registry = Get-Registry
            
            if (-not $registry.projects) {
                $registry.projects = @{}
            }
            
            # Convert to hashtable if needed for adding properties
            $projectsHash = @{}
            $registry.projects.PSObject.Properties | ForEach-Object {
                $projectsHash[$_.Name] = $_.Value
            }
            
            $projectsHash[$Add] = $targetPath.Path
            $registry.projects = [PSCustomObject]$projectsHash
            
            Save-Registry $registry
            Write-Host "✓ Registered '$Add' → $($targetPath.Path)" -ForegroundColor Green
        }
        
        'Remove' {
            $registry = Get-Registry
            
            $projectsHash = @{}
            $registry.projects.PSObject.Properties | ForEach-Object {
                if ($_.Name -ne $Remove) {
                    $projectsHash[$_.Name] = $_.Value
                }
            }
            
            if ($projectsHash.Count -eq $registry.projects.PSObject.Properties.Count) {
                Write-Host "✗ Project '$Remove' not found in registry" -ForegroundColor Red
                return
            }
            
            $registry.projects = [PSCustomObject]$projectsHash
            Save-Registry $registry
            Write-Host "✓ Removed '$Remove' from registry" -ForegroundColor Green
        }
        
        'List' {
            $registry = Get-Registry
            
            if ($registry.projects.PSObject.Properties.Count -eq 0) {
                Write-Host "No projects registered yet. Use 'Open-Project -Add <name>' to add one." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nRegistered Projects:" -ForegroundColor Cyan
            Write-Host ("=" * 60) -ForegroundColor Cyan
            
            $registry.projects.PSObject.Properties | Sort-Object Name | ForEach-Object {
                $exists = Test-Path $_.Value
                $status = if ($exists) { "✓" } else { "✗" }
                $color = if ($exists) { "Green" } else { "Red" }
                
                Write-Host "  $status " -ForegroundColor $color -NoNewline
                Write-Host "$($_.Name.PadRight(20))" -ForegroundColor White -NoNewline
                Write-Host " → $($_.Value)" -ForegroundColor Gray
            }
            
            Write-Host ""
        }
        
        'Recent' {
            $registry = Get-Registry
            
            if ($registry.recent.Count -eq 0) {
                Write-Host "No recently opened projects yet." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nRecently Opened Projects:" -ForegroundColor Cyan
            Write-Host ("=" * 60) -ForegroundColor Cyan
            
            $registry.recent | ForEach-Object {
                $lastOpened = [DateTime]::Parse($_.lastOpened)
                $timeAgo = (Get-Date) - $lastOpened
                
                $timeString = if ($timeAgo.TotalMinutes -lt 60) {
                    "{0} minutes ago" -f [math]::Floor($timeAgo.TotalMinutes)
                } elseif ($timeAgo.TotalHours -lt 24) {
                    "{0} hours ago" -f [math]::Floor($timeAgo.TotalHours)
                } else {
                    "{0} days ago" -f [math]::Floor($timeAgo.TotalDays)
                }
                
                Write-Host "  $($_.name.PadRight(20))" -ForegroundColor White -NoNewline
                Write-Host " → $($_.path)" -ForegroundColor Gray -NoNewline
                Write-Host " ($timeString)" -ForegroundColor DarkGray
            }
            
            Write-Host ""
        }
        
        'Edit' {
            Initialize-Registry
            
            if (Get-Command notepad -ErrorAction SilentlyContinue) {
                notepad $registryPath
            } elseif (Get-Command code -ErrorAction SilentlyContinue) {
                code $registryPath
            } else {
                Start-Process $registryPath
            }
        }
        
        'Open' {
            # If no name provided, just open current directory with opencode
            if (-not $Name) {
                if (Get-Command opencode -ErrorAction SilentlyContinue) {
                    opencode .
                } else {
                    Write-Error "opencode command not found. Please ensure it's installed and in your PATH."
                }
                return
            }
            
            $registry = Get-Registry
            
            $projectPath = $registry.projects.$Name
            
            if (-not $projectPath) {
                Write-Host "✗ Project '$Name' not found in registry" -ForegroundColor Red
                Write-Host "Available projects:" -ForegroundColor Yellow
                $registry.projects.PSObject.Properties.Name | ForEach-Object {
                    Write-Host "  - $_" -ForegroundColor Gray
                }
                return
            }
            
            if (-not (Test-Path $projectPath)) {
                Write-Host "✗ Project path no longer exists: $projectPath" -ForegroundColor Red
                Write-Host "Consider removing it with: Open-Project -Remove $Name" -ForegroundColor Yellow
                return
            }
            
            # Track in recent
            Add-RecentEntry -Name $Name -Path $projectPath
            
            # Open with opencode
            Write-Host "Opening '$Name' with opencode..." -ForegroundColor Green
            
            if (Get-Command opencode -ErrorAction SilentlyContinue) {
                Set-Location $projectPath
                opencode
            } else {
                Write-Host "✗ 'opencode' command not found. Please ensure it's installed and in your PATH." -ForegroundColor Red
                Write-Host "Navigating to project directory instead..." -ForegroundColor Yellow
                Set-Location $projectPath
            }
        }
    }
}
