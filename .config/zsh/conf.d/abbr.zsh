[[ -o interactive ]] || return

setopt extendedglob
typeset -Ag word_abbreviations
typeset -Ag space_abbreviations

word_abbreviations=(
    '...'       '../..'
)

space_abbreviations=(
    'mkdir'     'mkdir -p'
    'visudo'    'sudo visudo'
    'edit'      'sudoedit'
    'pkill'     'pkill -i'
    'pgrep'     'pgrep -i'
)

if type ansible &>/dev/null; then
    space_abbreviations+=(
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

function self-insert() {
    zle .self-insert
    setopt extendedglob
    [[ "${#RBUFFER}" == 0 || -n "${RBUFFER[1]%%[a-zA-Z0-9${WORDCHARS/-/\\-}]}" ]] || return
    local MATCH
    LBUFFER="${LBUFFER%%(#m)[a-zA-Z0-9${WORDCHARS/-/\\-}]#}"
    local abbreviation="${word_abbreviations[$MATCH]}"
    LBUFFER+="${abbreviation:-$MATCH}"
    if [[ "${abbreviation}" =~ "<CURSOR>" ]]; then
        RBUFFER="${LBUFFER[(ws:<CURSOR>:)2]}$RBUFFER"
        LBUFFER="${LBUFFER[(ws:<CURSOR>:)1]}"
    fi
}

function accept-line() {
    setopt extendedglob
    [[ "${#RBUFFER}" == 0 || -n "${RBUFFER[1]%%[a-zA-Z0-9${WORDCHARS/-/\\-}]}" ]] || { zle .accept-line; return }
    local MATCH
    LBUFFER="${LBUFFER%%(#m)[a-zA-Z0-9${WORDCHARS/-/\\-}]#}"
    local abbreviation="${space_abbreviations[$MATCH]}"
    LBUFFER+="${abbreviation:-$MATCH}"
    if [[ "${abbreviation}" =~ "<CURSOR>" ]]; then
        RBUFFER="${LBUFFER[(ws:<CURSOR>:)2]}$RBUFFER"
        LBUFFER="${LBUFFER[(ws:<CURSOR>:)1]}"
    fi
    zle .accept-line
}

function abbreviation-expand() {
    setopt extendedglob
    [[ "${#RBUFFER}" == 0 || -n "${RBUFFER[1]%%[a-zA-Z0-9${WORDCHARS/-/\\-}]}" ]] || { zle .self-insert; return }
    local MATCH
    LBUFFER="${LBUFFER%%(#m)[a-zA-Z0-9${WORDCHARS/-/\\-}]#}"
    local abbreviation="${space_abbreviations[$MATCH]}"
    LBUFFER+="${abbreviation:-$MATCH}"
    if [[ "${abbreviation}" =~ "<CURSOR>" ]]; then
        RBUFFER="${LBUFFER[(ws:<CURSOR>:)2]}$RBUFFER"
        LBUFFER="${LBUFFER[(ws:<CURSOR>:)1]}"
    else
        zle .self-insert
    fi
}

function self-insert-no-abbr() {
    zle .self-insert
}

function accept-line-no-abbr() {
    zle .accept-line
}

zle -N self-insert
zle -N accept-line
zle -N abbreviation-expand
zle -N self-insert-no-abbr
zle -N accept-line-no-abbr

bindkey " " abbreviation-expand
bindkey "^x " self-insert-no-abbr
bindkey "^x^M" accept-line-no-abbr
bindkey -M isearch " " .self-insert
