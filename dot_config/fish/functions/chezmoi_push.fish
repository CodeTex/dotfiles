function chezmoi_push --description "Re-add dotfiles, commit, and push chezmoi source changes"
    set -l message "feat: update dotfiles"
    if test (count $argv) -gt 0
        set message (string join ' ' $argv)
    end

    chezmoi re-add
    or return $status

    set -l pending (chezmoi git status -- --porcelain)
    or return $status

    if test -z "$pending"
        echo "chezmoi_push: no source changes to commit"
        return 0
    end

    chezmoi git add -- -A
    and chezmoi git commit -- -m "$message"
    and chezmoi git push
end
