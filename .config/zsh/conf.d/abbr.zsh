[[ -o interactive ]] || return

setopt extendedglob
typeset -Ag abbreviations

abbreviations=(
    '...'       '../..'
    'mkdir'     'mkdir -p'
    'visudo'    'sudo visudo'
    'edit'      'sudoedit'
    'pkill'     'pkill -i'
    'pgrep'     'pgrep -i'
)

if type ansible &>/dev/null; then
    abbreviations+=(
        apl 'ansible-playbook'
        apv 'ansible-playbook -e "<CURSOR>"'

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

test -z "$abbreviation_ifs" && abbreviation_ifs="$(tr -d "${WORDCHARS/-/\\-}" <<< '!"#%&'\''()*+,-./:;<=>?@[\]^_`{|}~¡¨«¬´·¸»¿•$') 
"

function self-insert() {
    zle .self-insert
    [[ "${#RBUFFER}" == 0 || "$abbreviation_ifs" =~ "${RBUFFER[1]}" ]] || return
    local LWORDS
    IFS="$abbreviation_ifs" read -A LWORDS <<< "${LBUFFER}"
    local WORD="${LWORDS[-1]}"
    local MATCH="${abbreviations[$WORD]}"
    test -n "$MATCH" || return
    LBUFFER="${LBUFFER:0:-$#WORD}$MATCH"
    if [[ "${MATCH}" =~ "<CURSOR>" ]]; then
        RBUFFER="${LBUFFER[(ws:<CURSOR>:)2]}$RBUFFER"
        LBUFFER="${LBUFFER[(ws:<CURSOR>:)1]}"
    fi
}

zle -N self-insert
