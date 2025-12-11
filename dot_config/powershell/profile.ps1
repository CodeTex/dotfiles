#Requires -Version 7.0

# ============================================
# INITIALIZATION GUARD
# ============================================
if ($Global:ProfileLoaded) { return }
$Global:ProfileLoaded = $true

# Skip for non-interactive shells
if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
    return
}

# ============================================
# CONFIGURATION
# ============================================
$script:ConfigRoot = Split-Path -Parent $PSCommandPath
$script:PowerShellConfig = $ConfigRoot

# ============================================
# LOAD MODULES
# ============================================
# Load in order: Environment → Functions → Aliases → Prompt

# 1. Environment Variables (fastest, no dependencies)
. "$PowerShellConfig\environment.ps1"

# 2. Functions (before aliases that depend on them)
Get-ChildItem "$PowerShellConfig\functions\*.ps1" | ForEach-Object {
    . $_.FullName
}

# 3. Aliases (depend on functions)
. "$PowerShellConfig\aliases.ps1"

# 4. Prompt Initialization (slowest, load last)
. "$PowerShellConfig\prompt.ps1"