# Shared PATH for Bash and Zsh

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Remove duplicates and unwanted entries
clean_path() {
    local new_path=""
    local seen=""
    local IFS=":"
    
    for dir in $PATH; do
        [ -z "$dir" ] && continue
        [[ "$dir" == /mnt/c/* ]] && continue
        [[ "$dir" == /usr/games ]] && continue
        [[ "$dir" == /usr/local/games ]] && continue
        case ":$seen:" in
            *":$dir:"*) continue ;;
        esac
        
        seen="$seen:$dir"
        if [ -z "$new_path" ]; then
            new_path="$dir"
        else
            new_path="$new_path:$dir"
        fi
    done
    
    export PATH="$new_path"
}

clean_path