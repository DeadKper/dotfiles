if [[ -o login ]] && type abbr &>/dev/null; then
    abbr_list=("${(@f)$(abbr list | awk -F= '{gsub(/^"|"$/,"",$1); print $1}')}")

    abbr_add() {
        if ! which "$1" &>/dev/null; then
            alias "$1"="$2"
        fi
        if ! (($abbr_list[(Ie)"$1"])); then
            abbr add -f -S "$1"="$2" &>/dev/null
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
    unset abbr_list
fi
