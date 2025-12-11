# ============================================
# ALIASES
# ============================================

# Navigation
Set-Alias -Name cd -Value Get-Go -Option AllScope
Set-Alias -Name zz -Value Get-GoBack

# Pretty ls
Set-Alias -Name l -Value Get-EzaBasic
Set-Alias -Name ll -Value Get-EzaLong
Set-Alias -Name la -Value Get-EzaAll
Set-Alias -Name lla -Value Get-EzaAllLong
Set-Alias -Name ls -Value Get-EzaBasic -Option AllScope
Set-Alias -Name lt -Value Get-EzaTree -Option AllScope

# System
Set-Alias -Name df -Value Get-Volume
Set-Alias -Name touch -Value New-File
Set-Alias -Name which -Value Show-Command

# Config editing
Set-Alias -Name sf -Value Reload-Profile
Set-Alias -Name vp -Value Get-EditProfile
Set-Alias -Name vpa -Value Get-EditProfileAliases
Set-Alias -Name vpe -Value Get-EditProfileEnv
Set-Alias -Name vpp -Value Get-EditProfilePrompt
Set-Alias -Name vpf -Value Get-EditProfileFunctions
Set-Alias -Name vv -Value Get-EditVim
Set-Alias -Name vw -Value Get-EditWezterm

# Git
Set-Alias -Name lgit -Value lazygit
Set-Alias -Name gcb -Value Clean-GitBranches
Set-Alias -Name gcl -Value Get-GitClone -Force -Option AllScope
Set-Alias -Name gs -Value Get-GitStatus -Force -Option AllScope
Set-Alias -Name gt -Value Get-GitTree -Force -Option AllScope
Set-Alias -Name gprune -Value Get-RemovePrunedBranches

# Misc
Set-Alias -Name oc -Value Open-Project
Set-Alias -Name ff -Value fastfetch
Set-Alias -Name flist -Value Get-FontList
Set-Alias -Name ghc -Value Get-GitHubContent

# Applications
Set-Alias -Name np -Value "$env:windir\System32\notepad.exe"
Set-Alias -Name npp -Value "$env:ProgramFiles\Notepad++\notepad++.exe"
Set-Alias -Name make -Value "$env:ProgramData\mingw64\mingw64\bin\mingw32-make.exe"
