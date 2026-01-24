# ============================================
# ALIASES
# ============================================

# ============================================
# NAVIGATION & DIRECTORY LISTING
# ============================================
# Smart navigation with zoxide integration
Set-Alias -Name cd -Value Set-SmartLocation -Option AllScope
Set-Alias -Name zz -Value Set-ParentLocation

# Enhanced directory listing with eza
Set-Alias -Name l -Value Show-Directory
Set-Alias -Name ll -Value Show-DirectoryLong
Set-Alias -Name la -Value Show-DirectoryAll
Set-Alias -Name lla -Value Show-DirectoryAllLong
Set-Alias -Name ls -Value Show-Directory -Option AllScope
Set-Alias -Name lt -Value Show-DirectoryTree -Option AllScope

# ============================================
# GIT OPERATIONS
# ============================================
# Core git operations
Set-Alias -Name gs -Value Show-GitStatus -Force -Option AllScope       # git status -sb
Set-Alias -Name gcl -Value Invoke-GitClone -Force -Option AllScope     # git clone
Set-Alias -Name gt -Value Show-GitTree -Force -Option AllScope         # git log tree view

# Branch management
Set-Alias -Name gbclean -Value Clear-GitBranches                       # Clean branches without remotes
Set-Alias -Name gbprune -Value Remove-PrunedBranches                   # Remove branches with gone remotes

# Git integrations
Set-Alias -Name lgit -Value lazygit                                    # Launch lazygit TUI

# ============================================
# CHEZMOI DOTFILE MANAGEMENT
# ============================================
# Status and inspection
Set-Alias -Name cgs -Value Show-ChezmoiStatus                          # Git status in chezmoi source
Set-Alias -Name cpd -Value Show-ChezmoiChanges                         # Pull and show diff

# File operations
Set-Alias -Name cra -Value Update-ChezmoiFiles                         # Re-add modified files
Set-Alias -Name cvim -Value Edit-ChezmoiFile                           # Edit file and apply

# Sync operations
Set-Alias -Name cpa -Value Sync-ChezmoiFromRemote                      # Pull from remote and apply
Set-Alias -Name cpush -Value Publish-ChezmoiChanges                    # Commit and push changes

# ============================================
# CONFIGURATION EDITING
# ============================================
# PowerShell config files
Set-Alias -Name vp -Value Edit-PowerShellProfile                       # Main profile
Set-Alias -Name vpa -Value Edit-PowerShellAliases                      # Aliases file
Set-Alias -Name vpe -Value Edit-PowerShellEnvironment                  # Environment variables
Set-Alias -Name vpp -Value Edit-PowerShellPrompt                       # Prompt configuration
Set-Alias -Name vpf -Value Edit-PowerShellFunctions                    # Functions directory

# Application configs
Set-Alias -Name vv -Value Edit-VimConfig                               # Vim configuration
Set-Alias -Name vw -Value Edit-WeztermConfig                           # WezTerm configuration

# Profile management
Set-Alias -Name sf -Value Reset-PowerShellProfile                      # Reload profile (source file)

# ============================================
# FILESYSTEM OPERATIONS
# ============================================
# Clipboard operations
Set-Alias -Name yc -Value Copy-FileContentToClipboard                  # Yank file contents to clipboard
Set-Alias -Name yf -Value Copy-ItemToClipboard                         # Yank file/folder to clipboard

# File creation
Set-Alias -Name touch -Value New-File                                  # Create empty file

# System utilities
Set-Alias -Name df -Value Get-Volume                                   # Disk space (like Unix df)
Set-Alias -Name which -Value Get-CommandDefinition                     # Show command location

# ============================================
# PYTHON/UV PACKAGE MANAGER
# ============================================
Set-Alias -Name uva -Value Add-UvScriptDependency                      # Add dependency to script
Set-Alias -Name uvr -Value Invoke-UvScript                             # Run Python script with uv

# ============================================
# UTILITIES
# ============================================
# Project management
Set-Alias -Name oc -Value Open-Project                                 # Open registered project

# Note taking
Set-Alias -Name note -Value New-Note                                   # Create/edit note with nvim

# GitHub utilities
Set-Alias -Name ghdl -Value Get-GitHubContent                          # Download files from GitHub

# System info
Set-Alias -Name ff -Value fastfetch                                    # Display system information

# ============================================
# SCOOP PACKAGE MANAGER
# ============================================
function Export-ScoopApps { scoop export > "$HOME\.config\scoop\scoopfile.json" }
function Import-ScoopApps { scoop import "$HOME\.config\scoop\scoopfile.json" }

Set-Alias -Name sce -Value Export-ScoopApps                             # Export installed apps
Set-Alias -Name sci -Value Import-ScoopApps                             # Import apps from file

# ============================================
# APPLICATIONS
# ============================================
# Conditionally set aliases for installed applications
if (Get-Command notepad -ErrorAction SilentlyContinue) {
    Set-Alias -Name np -Value (Get-Command notepad).Source
}
if (Test-Path "$env:ProgramFiles\Notepad++\notepad++.exe") {
    Set-Alias -Name npp -Value "$env:ProgramFiles\Notepad++\notepad++.exe"
}
if (Test-Path "$env:ProgramData\mingw64\mingw64\bin\mingw32-make.exe") {
    Set-Alias -Name make -Value "$env:ProgramData\mingw64\mingw64\bin\mingw32-make.exe"
}
