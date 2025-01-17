[[ -o interactive ]] || return

setopt extendedglob
zmodload zsh/zutil

typeset -Ag abbreviations_instant_global
typeset -Ag abbreviations_instant
typeset -Ag abbreviations_global
typeset -Ag abbreviations

function _abbr_help() {
    cat <<EOF
usage: abbr [options] [abbreviation]
# can use '<CURSOR>' to indicate where the cursor will end up after the expansion

options:
  -g, --global      make abbreviation globally available (this will expand even inside strings, use c-x+space to avoid expansion)
  -i, --instant     make abbreviation expand immediatly on match (word defined by \$WORDCHARS)
  -r, --remove      remove abbreviation
  -l, --list        list all abbreviations and exit
      --highlight   set highlight for non-instant abbreviations and exit (requires highlight string)
  -h, --help        print this help and exit
EOF
}

function abbr() {
    zparseopts -D -E -F -- -highlight:=highlight h=help -help=help l=list -list=list \
            i=instant -instant=instant g=global -global=global r=remove -remove=remove || return 1
    if [[ -n "$help" ]]; then
        _abbr_help
        return 0
    fi

    if [[ -n "$highlight" ]]; then
        if [[ ${#abbreviations_global[@]} -gt 0 ]]; then
            for abbr in "${(@k)abbreviations_global[@]}"; do
                if ! (( $+commands[$abbr] )); then
                    ZSH_HIGHLIGHT_REGEXP+=("(^|\\s)$abbr(\\s|\$)" "${highlight[2]}")
                fi
            done
        fi
        if [[ ${#abbreviations[@]} -gt 0 ]]; then
            for abbr in "${(@k)abbreviations[@]}"; do
                if ! (( $+commands[$abbr] )); then
                    ZSH_HIGHLIGHT_REGEXP+=("^\\s*$abbr(\\s|\$)" "${highlight[2]}")
                fi
            done
        fi
        return 0
    fi

    if [[ -n "$list" ]]; then
        echo global instant abbreviations:
        for abbr expansion in "${(@kv)abbreviations_instant_global[@]}"; do
            echo "  $abbr=$expansion"
        done | sort -t= -d
        echo global abbreviations:
        for abbr expansion in "${(@kv)abbreviations_global[@]}"; do
            echo "  $abbr=$expansion"
        done | sort -t= -d
        echo instant abbreviations:
        for abbr expansion in "${(@kv)abbreviations_instant[@]}"; do
            echo "  $abbr=$expansion"
        done | sort -t= -d
        echo abbreviations:
        for abbr expansion in "${(@kv)abbreviations[@]}"; do
            echo "  $abbr=$expansion"
        done | sort -t= -d
        return 0
    fi

    if [[ "$#" == 0 || "$#" > 1 ]]; then
        _abbr_help >&2
        return 1
    fi

    if [[ -n "$remove" ]]; then
        unset "abbreviations${instant:+_instant}${global:+_global}[$1]"
    else
        eval "abbreviations${instant:+_instant}${global:+_global}+=( \"\${1%=*}\" \"\${1##[^=]##=}\" )"
    fi
}

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
        local abbreviation="${abbreviations_instant_global[$MATCH]}"
        if [[ -z "$abbreviation" && -z "${LBUFFER// }" ]]; then
            local abbreviation="${abbreviations_instant[$MATCH]}"
        fi
    else
        local abbreviation="${abbreviations_global[$MATCH]}"
        if [[ -z "$abbreviation" && -z "${LBUFFER// }" ]]; then
            local abbreviation="${abbreviations[$MATCH]}"
        fi
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

abbr -gi '...'='../..'

abbr mkdir='mkdir -p'
abbr visudo='sudo visudo'
abbr edit='sudoedit'
abbr pkill='pkill -i'
abbr pgrep='pgrep -i'
abbr math='echo $(( <CURSOR> ))'

if which yadm &>/dev/null; then
    abbr yad='yadm add'
    abbr ycm='yadm commit -m "<CURSOR>"'
    abbr yca='yadm commit -am "<CURSOR>"'
    abbr yst='yadm status'
    abbr ydf='yadm diff'
    abbr ypl='yadm pull --rebase'
    abbr yps='yadm push'
fi

if which git &>/dev/null; then
    abbr gad='git add'
    abbr gcm='git commit -m "<CURSOR>"'
    abbr gca='git commit -am "<CURSOR>"'
    abbr gst='git status'
    abbr gdf='git diff'
    abbr gpl='git pull --rebase'
    abbr gps='git push'
fi

if which ansible &>/dev/null; then
    abbr apl='ansible-playbook'
    abbr apv='ansible-playbook -e "<CURSOR>"'
    abbr agl='ansible-galaxy'
    abbr agi='ansible-galaxy init'
    abbr aed='ansible-edit'
    abbr arn='ansible-run -m'
    abbr arc='ansible-run -m shell -a'
    abbr arx='ansible-run -m script -a'
    abbr arm='ansible-run -m role -a'
    abbr alg='ansible-logs'
    abbr atp='ansible-template'
fi
