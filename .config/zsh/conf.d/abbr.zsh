[[ -o interactive ]] || return

setopt extendedglob
typeset -Ag instant_abbreviations
typeset -Ag space_abbreviations

instant_abbreviations=(
    '...'   '../..'
)

space_abbreviations=(
    mkdir   'mkdir -p'
    visudo  'sudo visudo'
    edit    'sudoedit'
    pkill   'pkill -i'
    pgrep   'pgrep -i'
    math    'echo $(( <CURSOR> ))'
)

if which yadm &>/dev/null; then
    space_abbreviations+=(
        yad 'yadm add'
        ycm 'yadm commit -m "<CURSOR>"'
        yca 'yadm commit -am "<CURSOR>"'
        yst 'yadm status'
        ydf 'yadm diff'
        ypl 'yadm pull --rebase'
        yps 'yadm push'
    )
fi

if which git &>/dev/null; then
    space_abbreviations+=(
        gad 'git add'
        gcm 'git commit -m "<CURSOR>"'
        gca 'git commit -am "<CURSOR>"'
        gst 'git status'
        gdf 'git diff'
        gpl 'git pull --rebase'
        gps 'git push'
    )
fi

if which ansible &>/dev/null; then
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

function expand-abbreviation() {
    setopt extendedglob
    test "${3}" = instant && zle "${1}"
    if [[ "${#RBUFFER}" != 0 && -z "${RBUFFER[1]%%[a-zA-Z0-9${2}]}" ]]; then
        test "${3}" != instant && zle "${1}"
        return
    fi
    local MATCH
    LBUFFER="${LBUFFER%%(#m)[a-zA-Z0-9${2}]#}"
    if test "${3}" = instant; then
        local abbreviation="${instant_abbreviations[$MATCH]}"
    else
        local abbreviation="${space_abbreviations[$MATCH]}"
    fi
    LBUFFER+="${abbreviation:-$MATCH}"
    if [[ "${abbreviation}" =~ "<CURSOR>" ]]; then
        RBUFFER="${LBUFFER[(ws:<CURSOR>:)2]}$RBUFFER"
        LBUFFER="${LBUFFER[(ws:<CURSOR>:)1]}"
    else
        test "${3}" = space && zle "${1}"
    fi
    test "${3}" = line && zle "${1}"
}

function self-insert() {
    expand-abbreviation .self-insert "${WORDCHARS/-/\\-}" instant
}

function accept-line() {
    expand-abbreviation .accept-line _ line
}

function space-expansion() {
    expand-abbreviation .self-insert _ space
}

zle -N self-insert
zle -N accept-line
zle -N space-expansion

bindkey " " space-expansion
bindkey "^x " .self-insert
bindkey "^x^M" .accept-line
bindkey -M isearch " " .self-insert
