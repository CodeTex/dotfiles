# fzf with a file preview and focused-file header
function fz() {
    fzf --style full \
        --preview 'fzf-preview.sh {}' \
        --bind 'focus:transform-header:file --brief {}' "$@"
}

# Run Yazi and change to its final working directory
function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd" || builtin true
    command rm -f -- "$tmp"
}

# Remove local branches whose upstream has been deleted
function gprune() {
    git fetch --prune || return

    local branch answer
    local -a branches
    branches=()

    while IFS= read -r branch; do
        branches+=("$branch")
    done < <(
        git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads |
            awk '$2 == "[gone]" { print $1 }'
    )

    ((${#branches[@]})) || { echo "No gone branches."; return; }

    printf 'Gone branches:\n'
    printf '  %s\n' "${branches[@]}"
    printf 'Delete them? [y/N] '
    read -r answer

    [[ $answer == [yY] ]] || { echo "Cancelled."; return; }

    git branch -D "${branches[@]}"
}

# Show resolved uv package versions and newer available versions
function uvl() {
    uv tree --no-dev --outdated --format json --preview-features json-output |
        jq -r '
          [.resolution[]
           | select(.kind == "package")
           | [.name, .version, (.latest_version // "")]]
          | unique_by(.[0:2])
          | sort_by(.[0], .[1])[]
          | @tsv
        ' |
        column -t -s $'\t'
}
