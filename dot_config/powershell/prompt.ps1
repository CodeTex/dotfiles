# ============================================
# PROMPT INITIALIZATION
# ============================================

# Custom update check
# Test-PowerShellUpdate

# Starship
# if (Get-Command starship -ErrorAction SilentlyContinue) {
#     Invoke-Expression (& starship init powershell)
# } else {
#     Write-Warning "Starship not found. Install with: winget install starship"
# }

# Oh My Posh
# if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
	# oh-my-posh init pwsh --config ~\.config\oh-my-posh\themes\spaceship.omp.json | Invoke-Expression
# } else {
	# Write-Warning "Oh-My-Posh not found. Install with: winget install oh-my-posh"
# }

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
