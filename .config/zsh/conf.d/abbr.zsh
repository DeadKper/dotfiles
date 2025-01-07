if type abbr &>/dev/null; then
    if test -n "$_LOGIN_ABBR"; then
        test -f "${XDG_CONFIG_HOME:=$HOME/.config}/zsh-abbr/user-aliases" && source "${XDG_CONFIG_HOME:=$HOME/.config}/zsh-abbr/user-aliases"
        return
    fi

    export _LOGIN_ABBR=true

    local abbr_list=("${(@f)$(abbr list | awk -F= '{gsub(/^"|"$/,"",$1); print $1}')}")

    abbr_add() {
        if ! which "$(sed "s/ .*$//" <<< "$1")" &>/dev/null; then
            local flags=(--quiet)
            local abbr_alias=true
            alias "$1"="$2"
        else
            local flags=(--quieter --force)
            local abbr_alias=''
        fi
        if ! (($abbr_list[(Ie)$1])); then
            abbr add "${flags[@]}" "$1"="$2"
            if test "$abbr_alias" = true && ! grep -qwF "alias \"$1\"=\"$2\"" "${XDG_CONFIG_HOME:=$HOME/.config}/zsh-abbr/user-aliases" 2>/dev/null; then
                echo "alias \"$1\"=\"$2\"" >>! "${XDG_CONFIG_HOME:=$HOME/.config}/zsh-abbr/user-aliases"
            fi
        fi
    }

    abbr_add mkdir 'mkdir -p'
    abbr_add '...' '../..'
    abbr_add '....' '../../..'
    abbr_add '.....' '../../../..'
    abbr_add 'edit' 'sudoedit'
    abbr_add 'visudo' 'sudo visudo'

    if type ansible &>/dev/null; then
        abbr_add apl 'ansible-playbook'
        abbr_add apv 'ansible-playbook --extra-vars'
        abbr_add apa 'ansible-playbook asd.yaml -i'

        abbr_add agl 'ansible-galaxy'
        abbr_add agi 'ansible-galaxy init'

        abbr_add aed 'ansible-edit'

        abbr_add arn 'ansible-run -m'
        abbr_add arc 'ansible-run -m shell -a'
        abbr_add arx 'ansible-run -m script -a'

        abbr_add alg 'ansible-logs'

        abbr_add atp 'ansible-template'
    fi

    unset -f abbr_add
fi
