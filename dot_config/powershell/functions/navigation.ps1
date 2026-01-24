# ============================================
# NAVIGATION FUNCTIONS
# ============================================

function Set-SmartLocation {
    <#
    .SYNOPSIS
        Navigate to directory using smart navigation with zoxide
    .DESCRIPTION
        Uses zoxide for frecency-based directory navigation if available,
        otherwise falls back to standard Set-Location
    .EXAMPLE
        Set-SmartLocation ~/projects
    #>
    if (Get-Command z -ErrorAction SilentlyContinue) {
        z @args
    } else {
        Set-Location @args
    }
}

function Set-ParentLocation {
    <#
    .SYNOPSIS
        Navigate to parent directory using smart navigation
    .DESCRIPTION
        Uses zoxide to navigate to parent directory if available,
        otherwise falls back to standard Set-Location
    .EXAMPLE
        Set-ParentLocation
    #>
    if (Get-Command z -ErrorAction SilentlyContinue) {
        z ..
    } else {
        Set-Location ..
    }
}

# ============================================
# DIRECTORY LISTING FUNCTIONS (EZA)
# ============================================

$script:ezaBaseOptions = '--color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first'

function Show-Directory {
    <#
    .SYNOPSIS
        Display directory contents with enhanced formatting
    .DESCRIPTION
        Uses eza to show directory contents with icons and colors
    .EXAMPLE
        Show-Directory
    #>
    eza $script:ezaBaseOptions.Split() @args
}

function Show-DirectoryLong {
    <#
    .SYNOPSIS
        Display directory contents in detailed long format
    .DESCRIPTION
        Shows detailed file information including permissions, size, and git status
    .EXAMPLE
        Show-DirectoryLong
    #>
    eza $script:ezaBaseOptions.Split() --long --git --header @args
}

function Show-DirectoryAll {
    <#
    .SYNOPSIS
        Display all directory contents including hidden files
    .DESCRIPTION
        Shows all files and directories including those starting with dot
    .EXAMPLE
        Show-DirectoryAll
    #>
    eza $script:ezaBaseOptions.Split() --all @args
}

function Show-DirectoryAllLong {
    <#
    .SYNOPSIS
        Display all directory contents in detailed long format
    .DESCRIPTION
        Shows detailed information for all files including hidden files
    .EXAMPLE
        Show-DirectoryAllLong
    #>
    eza $script:ezaBaseOptions.Split() --all --long --git --header @args
}

function Show-DirectoryTree {
    <#
    .SYNOPSIS
        Display directory contents as a tree structure
    .DESCRIPTION
        Shows directory hierarchy in tree format with 2 levels of depth
    .EXAMPLE
        Show-DirectoryTree
    .EXAMPLE
        Show-DirectoryTree --level=3
    #>
    eza $script:ezaBaseOptions.Split() --tree --level=2 --long --header @args
}
