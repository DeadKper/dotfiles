if [[ -o login ]] && test -z "${ZSH_LOGIN+1}" && type abbr &>/dev/null; then
    abbrs=("${(@f)$(abbr list | awk -F= '{gsub(/^"|"$/,"",$1); print $1}')}")
    add_abbr() {
        if which "$1" &>/dev/null; then
            local binary=true
        else
            local binary=""
        fi
        alias "$1"="$2"
        if ! (($abbrs[(Ie)$1])); then
            abbr add "$1"="$2" &>/dev/null
        fi
        if test -n "$binary" || grep -qE '^\.+$' <<< "$1"; then
            unalias "$1"
        fi
    }

    add_abbr mkdir 'mkdir -p'
    add_abbr '...' '../..'
    add_abbr '....' '../../..'
    add_abbr '.....' '../../../..'

    if type ansible &>/dev/null; then
        add_abbr apl 'ansible-playbook'
        add_abbr apv 'ansible-playbook --extra-vars'
        add_abbr apa 'ansible-playbook asd.yaml -i'

        add_abbr agl 'ansible-galaxy'
        add_abbr agi 'ansible-galaxy init'

        add_abbr aed 'ansible-edit'

        add_abbr arn 'ansible-run -m'
        add_abbr arc 'ansible-run -m shell -a'
        add_abbr arx 'ansible-run -m script -a'

        add_abbr alg 'ansible-logs'

        add_abbr atp 'ansible-template'
    fi
fi
