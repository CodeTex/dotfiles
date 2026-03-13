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
