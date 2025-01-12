[[ -o interactive ]] || return

setopt extendedglob
typeset -Ag abbrs

abbrs=(
    '...'       '../..'
    'mkdir'     'mkdir -p'
    'visudo'    'sudo visudo'
    'edit'      'sudoedit'
)

if type ansible &>/dev/null; then
    abbrs+=(
        apl 'ansible-playbook'
        apv 'ansible-playbook --extra-vars'
        apa 'ansible-playbook asd.yaml -i'

        agl 'ansible-galaxy'
        agi 'ansible-galaxy init'

        aed 'ansible-edit'

        arn 'ansible-run -m'
        arc 'ansible-run -m shell -a'
        arx 'ansible-run -m script -a'
        arm 'ansible-run -m role -a'

        alg 'ansible-logs'

        atp 'ansible-template'
    )
fi

test -z "$abbr_ifs" && abbr_ifs="$(tr -d "${WORDCHARS/-/\\-}" <<< '!"#%&'\''()*+,-./:;<=>?@[\]^_`{|}~¡¨«¬´·¸»¿•$') 
"

function self-insert() {
    zle .self-insert
    IFS="$abbr_ifs" read -A RWORDS <<< "z${RBUFFER}"
    test "${RWORDS[1]}" = z || return
    IFS="$abbr_ifs" read -A LWORDS <<< "${LBUFFER}"
    local WORD="${LWORDS[-1]}"
    local MATCH="${abbrs[$WORD]}"
    test -n "$MATCH" || return
    LBUFFER="${LBUFFER:0:-$#WORD}$MATCH"
    if [[ "${MATCH}" =~ "<CURSOR>" ]]; then
        RBUFFER="${LBUFFER[(ws:<CURSOR>:)2]}$RBUFFER"
        LBUFFER="${LBUFFER[(ws:<CURSOR>:)1]}"
    fi
}

zle -N self-insert
