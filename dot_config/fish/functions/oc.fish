function oc --description "Open or manage saved project paths"
    set -l registry "$HOME/.config/powershell/project-registry.json"
    set -l registry_dir (dirname "$registry")
    set -l tmp "$registry.tmp"

    function __oc_init_registry --no-scope-shadowing
        if not test -d "$registry_dir"
            mkdir -p "$registry_dir"
        end

        if not test -f "$registry"
            printf '{"projects":{},"recent":[]}' > "$registry"
        end
    end

    function __oc_require_jq
        if not type -q jq
            echo "oc: jq is required for registry operations"
            return 1
        end
        return 0
    end

    function __oc_update_recent --no-scope-shadowing
        set -l entry_name "$argv[1]"
        set -l entry_path "$argv[2]"

        if not __oc_require_jq
            return 1
        end

        jq \
            --arg name "$entry_name" \
            --arg path "$entry_path" \
            --arg opened (date -Iseconds) \
            '.recent = ([{"name": $name, "path": $path, "lastOpened": $opened}] + (.recent | map(select(.name != $name)))) | .recent = .recent[:10]' \
            "$registry" > "$tmp"

        and mv "$tmp" "$registry"
    end

    __oc_init_registry

    if test (count $argv) -eq 0
        if type -q opencode
            opencode .
        else
            echo "oc: opencode command not found"
            return 1
        end
        return 0
    end

    set -l command "$argv[1]"

    switch "$command"
        case add
            if test (count $argv) -lt 2
                echo "Usage: oc add <name> [path]"
                return 1
            end

            if not __oc_require_jq
                return 1
            end

            set -l name "$argv[2]"
            set -l raw_path
            if test (count $argv) -ge 3
                set raw_path "$argv[3]"
            else
                set raw_path (pwd)
            end

            if not test -e "$raw_path"
                echo "oc: path not found: $raw_path"
                return 1
            end

            set -l target_path (realpath "$raw_path")
            if test -f "$target_path"
                set target_path (dirname "$target_path")
            end

            jq --arg name "$name" --arg path "$target_path" '.projects[$name] = $path' "$registry" > "$tmp"
            and mv "$tmp" "$registry"
            and echo "Registered '$name' -> $target_path"
            return $status

        case remove rm del
            if test (count $argv) -lt 2
                echo "Usage: oc remove <name>"
                return 1
            end

            if not __oc_require_jq
                return 1
            end

            set -l name "$argv[2]"
            set -l existing (jq -r --arg name "$name" '.projects[$name] // empty' "$registry")
            if test -z "$existing"
                echo "oc: project '$name' not found"
                return 1
            end

            jq --arg name "$name" 'del(.projects[$name])' "$registry" > "$tmp"
            and mv "$tmp" "$registry"
            and echo "Removed '$name'"
            return $status

        case list ls
            if not __oc_require_jq
                return 1
            end

            set -l count (jq '.projects | keys | length' "$registry")
            if test "$count" = "0"
                echo "No saved projects. Add one with: oc add <name> [path]"
                return 0
            end

            jq -r '.projects | to_entries[] | "\(.key)\t\(.value)"' "$registry" | while read -l name path
                if test -d "$path"
                    echo "$name -> $path"
                else
                    echo "$name -> $path (missing)"
                end
            end
            return 0

        case recent
            if not __oc_require_jq
                return 1
            end

            set -l count (jq '.recent | length' "$registry")
            if test "$count" = "0"
                echo "No recent projects yet."
                return 0
            end

            jq -r '.recent[] | "\(.name)\t\(.path)\t\(.lastOpened)"' "$registry" | while read -l name path opened
                echo "$name -> $path ($opened)"
            end
            return 0

        case edit
            if type -q $EDITOR
                $EDITOR "$registry"
            else if type -q nvim
                nvim "$registry"
            else if type -q vim
                vim "$registry"
            else
                echo "oc: no editor found; set EDITOR or install nvim/vim"
                return 1
            end
            return 0

        case help -h --help
            echo "oc usage:"
            echo "  oc <name-or-path>      Open saved project or path with opencode"
            echo "  oc add <name> [path]   Save current or specified path"
            echo "  oc remove <name>       Remove saved project"
            echo "  oc list                List saved projects"
            echo "  oc recent              List recently opened projects"
            echo "  oc edit                Edit registry JSON"
            return 0
    end

    if not __oc_require_jq
        return 1
    end

    set -l key_or_path "$command"
    set -l target_path
    set -l recent_name "$key_or_path"

    if test -e "$key_or_path"
        set target_path (realpath "$key_or_path")
    else
        set target_path (jq -r --arg name "$key_or_path" '.projects[$name] // empty' "$registry")
    end

    if test -z "$target_path"
        echo "oc: '$key_or_path' not found as path or saved project"
        return 1
    end

    if test -f "$target_path"
        set target_path (dirname "$target_path")
    end

    if not test -d "$target_path"
        echo "oc: target directory does not exist: $target_path"
        return 1
    end

    __oc_update_recent "$recent_name" "$target_path"

    cd "$target_path"
    if type -q opencode
        opencode
    else
        echo "oc: opencode command not found; changed directory only"
    end
end
