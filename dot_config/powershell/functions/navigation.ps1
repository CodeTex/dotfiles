# ============================================
# NAVIGATION FUNCTIONS
# ============================================

function Get-Go {
    z @args
}


function Get-GoBack {
    z ../.
}

$ezaBase = '--color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first'

function Get-EzaBasic { 
    eza $ezaBase.Split() @args 
}

function Get-EzaLong { 
    eza $ezaBase.Split() --long --git --header @args 
}

function Get-EzaAll { 
    eza $ezaBase.Split() --all @args 
}

function Get-EzaAllLong { 
    eza $ezaBase.Split() --all --long --git --header @args 
}

function Get-EzaTree { 
    eza $ezaBase.Split() --tree --level=2 --long --header @args 
}