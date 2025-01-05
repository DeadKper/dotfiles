if [[ -o login ]] && type abbr &>/dev/null; then
    abbr_list=("${(@f)$(abbr list | awk -F= '{gsub(/^"|"$/,"",$1); print $1}')}")

    abbr_add() {
        if ! (($abbr_list[(Ie)$1])); then
            abbr add -f -S "$1"="$2" &>/dev/null
        fi
    }

    abbr_ali() {
        abbr_add "$1" "$2"
        alias "$1"="$2"
    }

    abbr_add mkdir 'mkdir -p'
    abbr_add '...' '../..'
    abbr_add '....' '../../..'
    abbr_add '.....' '../../../..'
    abbr_ali 'edit' 'sudoedit'
    abbr_add 'visudo' 'sudo visudo'

    if type ansible &>/dev/null; then
        abbr_ali apl 'ansible-playbook'
        abbr_ali apv 'ansible-playbook --extra-vars'
        abbr_ali apa 'ansible-playbook asd.yaml -i'

        abbr_ali agl 'ansible-galaxy'
        abbr_ali agi 'ansible-galaxy init'

        abbr_ali aed 'ansible-edit'

        abbr_ali arn 'ansible-run -m'
        abbr_ali arc 'ansible-run -m shell -a'
        abbr_ali arx 'ansible-run -m script -a'

        abbr_ali alg 'ansible-logs'

        abbr_ali atp 'ansible-template'
    fi
fi
