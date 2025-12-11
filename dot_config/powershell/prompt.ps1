# ============================================
# PROMPT INITIALIZATION
# ============================================

# Custom update check
# Test-PowerShellUpdate

# Starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
} else {
    Write-Warning "Starship not found. Install with: winget install starship"
}

# Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
} else {
    Write-Warning "Zoxide not found. Install with: winget install zoxide"
}

# Fastfetch (optional startup display)
# Uncomment if you want fastfetch on startup
# if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
#     fastfetch
# }