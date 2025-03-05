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
        for abbr in "${(@k)abbreviations_global[@]}"; do
            if ! (( $+commands[$abbr] )) && [[ "$abbr" = "${abbr// }" ]]; then
                ZSH_HIGHLIGHT_REGEXP+=("(^|\\s)$abbr(\\s|\$)" "${highlight[2]}")
            fi
        done
        for abbr in "${(@k)abbreviations[@]}"; do
            if ! (( $+commands[$abbr] )) && [[ "$abbr" = "${abbr// }" ]]; then
                ZSH_HIGHLIGHT_REGEXP+=("^\\s*$abbr(\\s|\$)" "${highlight[2]}")
            fi
        done
        return 0
    fi

    if [[ -n "$list" ]]; then
        echo "${global:+global }${instant:+instant }abbreviations:"
        eval 'test "${#abbreviations'${instant:+_instant}${global:+_global}'[@]}" -gt 0 && \
            printf "  %s=%s\n" "${(@kv)abbreviations'${instant:+_instant}${global:+_global}'[@]}"' | sort -t= -k1d
        return 0
    fi

    if [[ "$#" == 0 || "$#" > 1 ]]; then
        _abbr_help >&2
        return 1
    fi

    if [[ -n "$remove" ]]; then
        unset "abbreviations${instant:+_instant}${global:+_global}[$1]"
    else
        eval "abbreviations${instant:+_instant}${global:+_global}+=( \"\${1%%=*}\" \"\${1##[^=]##=}\" )"
    fi
}

function expand-abbreviation() {
    test "${3}" = instant && zle "${1}"
    if [[ "${#RBUFFER}" != 0 && -z "${RBUFFER[1]%%[a-zA-Z0-9${~2}]}" ]]; then
        test "${3}" != instant && zle "${1}"
        return
    fi
    local MATCH
    local abbreviation
    LBUFFER="${LBUFFER%%(#m)[a-zA-Z0-9${~2}]#}"
    local instant
    test "${3}" = instant && instant=true || unset instant
    eval '
    abbreviation="${abbreviations'${instant:+_instant}'_global[$MATCH]}"
    if [[ -z "$abbreviation" ]]; then
        abbreviation="${abbreviations'${instant:+_instant}'[${LBUFFER## #}$MATCH]}"
        [[ -z "$abbreviation" ]] || LBUFFER="${LBUFFER//[[:graph:]][[:print:]]#}"
    fi'
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
    setopt extendedglob
    local MATCH
    expand-abbreviation .self-insert "${WORDCHARS//(#m)[\[\]\-]/\\$MATCH}" instant
}

function accept-line() {
    setopt extendedglob
    expand-abbreviation .accept-line _ line
}

function space-expansion() {
    setopt extendedglob
    expand-abbreviation .self-insert _ space
}

zle -N self-insert
zle -N accept-line
zle -N space-expansion

bindkey " " space-expansion
bindkey "^x " .self-insert
bindkey "^x^M" .accept-line
bindkey -M isearch " " .self-insert

local dots='..'

for _ in $(seq 5); do
    abbr -i "${dots}."="${dots}/.."
    which zoxide &>/dev/null && abbr -i "z ${dots}."="z ${dots}/.."
    abbr -i "cd ${dots}."="cd ${dots}/.."
    dots+="/.."
done

abbr mkdir='mkdir -p'
abbr visudo='sudo visudo'
abbr edit='sudoedit'
abbr pkill='pkill -i'
abbr pgrep='pgrep -i'
abbr math='echo $(( <CURSOR> ))'
abbr printn="printf '%s\\n'"
abbr -g iargs='xargs -d \\n -I {}'
abbr -g nargs='xargs -d \\n -n 1'

if which pacman &>/dev/null; then
    abbr pac=pacman
    abbr 'pacman -Syu=sudo pacman -Syu'
    abbr 'pacman -Sy=sudo pacman -Sy'
    abbr 'pacman -S=sudo pacman -S'
    abbr 'pacman -Rns=sudo pacman -Rns'
    abbr 'pacman -R=sudo pacman -Rns'
fi

if which dnf &>/dev/null; then
    abbr 'dnf install=sudo dnf install'
    abbr 'dnf in=sudo dnf install'
    abbr 'dnf remove=sudo dnf remove'
    abbr 'dnf rm=sudo dnf remove'
    abbr 'dnf update=sudo dnf update'
    abbr 'dnf up=sudo dnf update'
    abbr 'dnf se=dnf search'
fi

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
