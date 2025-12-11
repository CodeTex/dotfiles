# ============================================
# CHEZMOI FUNCTIONS
# ============================================

function Invoke-ChezmoiGitAdd {
    chezmoi git add @args
}

function Invoke-ChezmoiGitCommit {
    chezmoi git -- commit -m @args
}

function Invoke-ChezmoiGitStatus {
    chezmoi git status @args
}

function Invoke-ChezmoiGitPush {
    chezmoi git push @args
}
