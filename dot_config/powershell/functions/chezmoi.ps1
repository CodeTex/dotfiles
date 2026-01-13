# ============================================
# CHEZMOI FUNCTIONS
# ============================================

# Get Chezmoi home directory
$CHEZMOI_HOME = chezmoi source-path

# cgs - Chezmoi Git Status
function Invoke-ChezmoiGitStatus {
    Push-Location $CHEZMOI_HOME
    git status
    Pop-Location
}

# cra - Chezmoi Re-Add
function Invoke-ChezmoiReAdd {
    chezmoi re-add @args
}

# cpa - Chezmoi Pull and Apply
function Invoke-ChezmoiPullApply {
    Push-Location $CHEZMOI_HOME
    git pull
    Pop-Location
    chezmoi apply
}

# cpd - Chezmoi Pull and Diff
function Invoke-ChezmoiPullDiff {
    Push-Location $CHEZMOI_HOME
    git pull
    Pop-Location
    chezmoi diff
}

# cpush - Chezmoi Push (re-add, commit, push)
function Invoke-ChezmoiPush {
    param(
        [string]$Message = "feat: update dotfiles"
    )
    
    chezmoi re-add
    Push-Location $CHEZMOI_HOME
    git add .
    git commit -m $Message
    git push
    Pop-Location
}

# cvim - Chezmoi Edit with Apply
function Invoke-ChezmoiEditApply {
    chezmoi edit --apply @args
}