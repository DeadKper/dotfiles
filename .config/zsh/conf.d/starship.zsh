if [[ -o interactive ]] && command -v starship &>/dev/null; then

    # ── Fast profile prompts ───────────────────────────────────────────────────
    function _starship_fast_prompt {
        if [[ -n $_STARSHIP_LEFT_SEGMENT ]]; then
            print -rn -- "${_STARSHIP_LEFT_SEGMENT}"
            return
        fi
        starship prompt --profile fast_left --status="${_STARSHIP_LAST_EXIT:-0}"
    }

    function _starship_fast_rprompt {
        if [[ -n $_STARSHIP_RIGHT_SEGMENT ]]; then
            print -rn -- "$_STARSHIP_RIGHT_SEGMENT"
            return
        fi
        starship prompt --profile fast_right --status="${_STARSHIP_LAST_EXIT:-0}"
    }

    # ── Phase guard: instant prompt only ─────────────────────────────────────────
    if [[ ${1:-} == instant ]]; then

        function _instant_prompt {
            print -n $'\e7'

            print -Pn -- "$(_starship_fast_prompt)"

            (( ${COLUMNS:-0} > 0 )) && print -n $'\e[3G'
            unsetopt prompt_cr prompt_sp

            function _instant_prompt_cleanup {
                print -n $'\e[?25l\e8\e[J\e[?25h'
                unfunction _instant_prompt_cleanup
            }

            function _instant_prompt_precmd {
                function _instant_prompt_sched_last {
                    (( ${+functions[_instant_prompt_cleanup]} )) || return
                    _instant_prompt_cleanup
                    setopt no_local_options prompt_cr prompt_sp
                }
                zmodload zsh/sched
                sched +0 _instant_prompt_sched_last
                precmd_functions=("${(@)precmd_functions:#_instant_prompt_precmd}")
            }

            precmd_functions=(_instant_prompt_precmd "${precmd_functions[@]}")
        }

        return 0
    fi

    # ── Defaults ──────────────────────────────────────────────────────────────────
    STARSHIP_ASYNC_LEFT=DEFAULT
    STARSHIP_TRANS_LEFT=transient_left
    STARSHIP_TRANS_RIGHT=transient_right
    STARSHIP_ASYNC_GIT_CACHE=1

    export STARSHIP_LOG=error

    # ── Starship init interception ────────────────────────────────────────────────
    # Strip PROMPT/RPROMPT/PROMPT2 assignments and starship's own precmd hook.
    # prompt_starship_precmd still gets defined (captures STARSHIP_CMD_STATUS etc.).
    # preexec hook still registers (timing). We own precmd entirely via _starship_precmd.
    if [[ -n "${STARSHIP_TRANS_LEFT+1}" || -n "${STARSHIP_TRANS_RIGHT+1}" || -n "${STARSHIP_ASYNC_LEFT+1}" || -n "${STARSHIP_ASYNC_RIGHT+1}" ]]; then
        local _starship_init
        _starship_init="$(starship init zsh)"
        _starship_init="$(printf '%s\n' "$_starship_init" | sed '/^PROMPT=/d; /^RPROMPT=/d; /^PROMPT2=/d; /add-zsh-hook precmd prompt_starship_precmd/d')"
        eval "$_starship_init"
        unset _starship_init
    else
        eval "$(starship init zsh)" # Fallback to allow correct functionanility if async and trans is not beign used
    fi

    # ── Transient state ───────────────────────────────────────────────────────────
    typeset -gi _STARSHIP_LAST_EXIT=0
    typeset -gi _STARSHIP_LINE_FINISHED=0
    typeset -g  _STARSHIP_SAVED_LEFT=""
    typeset -g  _STARSHIP_SAVED_RIGHT=""

    # ── Async state ───────────────────────────────────────────────────────────────
    typeset -g  _STARSHIP_ASYNC_PWD=""
    typeset -g  _STARSHIP_LEFT_SEGMENT=""
    typeset -g  _STARSHIP_RIGHT_SEGMENT=""
    typeset -gi _STARSHIP_ASYNC_GIT=0

    setopt PROMPT_SUBST

    # ── zsh-async bootstrap ───────────────────────────────────────────────────────
    local async_zsh="${ZIM_HOME:-${ZDOTDIR:-${HOME}}/.zim}/modules/zsh-async/async.zsh"
    [[ -f $async_zsh ]] && source "$async_zsh"
    unset async_zsh

    # ── Async job functions ───────────────────────────────────────────────────────
    function _starship_render_left {
        cd "$1" 2>/dev/null || return 1
        local profile_args=()
        [[ $STARSHIP_ASYNC_LEFT != DEFAULT ]] && profile_args=(--profile "$STARSHIP_ASYNC_LEFT")
        starship prompt "${profile_args[@]}" --status="$2" --pipestatus="$3" \
            --cmd-duration="$4" --jobs="$5" --terminal-width="$6" --keymap="$7"
    }

    function _starship_render_right {
        local profile_args=()
        if [[ $STARSHIP_ASYNC_RIGHT == DEFAULT ]]; then
            profile_args=(--right)
        else
            profile_args=(--profile "$STARSHIP_ASYNC_RIGHT")
        fi
        starship prompt "${profile_args[@]}" --status="$1" --pipestatus="$2" \
            --cmd-duration="$3" --jobs="$4" --terminal-width="$5" --keymap="$6"
    }

    # ── Persistent async workers ──────────────────────────────────────────────────
    if [[ -n "${STARSHIP_ASYNC_LEFT+1}" ]] && (( ${+functions[async_start_worker]} )); then
        async_start_worker _starship_left_worker -u
        async_register_callback _starship_left_worker _starship_left_callback
    fi

    if [[ -n "${STARSHIP_ASYNC_RIGHT+1}" ]] && (( ${+functions[async_start_worker]} )); then
        async_start_worker _starship_right_worker -u
        async_register_callback _starship_right_worker _starship_right_callback
    fi

    # ── Async callbacks ───────────────────────────────────────────────────────────
    function _starship_left_callback {
        local job=$1 ret=$2 stdout=$3 exec_time=$4 stderr=$5 has_next=$6
        [[ $job == '[async]' ]] && return
        [[ $PWD != $_STARSHIP_ASYNC_PWD ]] && return
        (( has_next )) && return
        if (( ! _STARSHIP_LINE_FINISHED )) && zle && [[ $ret -eq 0 ]]; then
            _STARSHIP_LEFT_SEGMENT="$stdout"
            zle reset-prompt
        fi
    }

    function _starship_right_callback {
        local job=$1 ret=$2 stdout=$3 exec_time=$4 stderr=$5 has_next=$6
        [[ $job == '[async]' ]] && return
        [[ $PWD != $_STARSHIP_ASYNC_PWD ]] && return
        (( has_next )) && return
        if (( ! _STARSHIP_LINE_FINISHED )) && zle && [[ $ret -eq 0 ]]; then
            _STARSHIP_RIGHT_SEGMENT="$stdout"
            zle reset-prompt
        fi
    }

    # ── Transient prompt ──────────────────────────────────────────────────────────
    if [[ -n "${STARSHIP_TRANS_LEFT+1}" || -n "${STARSHIP_TRANS_RIGHT+1}" ]]; then
        function _starship_transient_prompt {
            _STARSHIP_LINE_FINISHED=1
            if [[ "$PWD" != "$_STARSHIP_SAVED_PWD" ]]; then
                _STARSHIP_SAVED_PWD="$PWD"
                return
            fi
            PROMPT="$_STARSHIP_SAVED_LEFT" RPROMPT="$_STARSHIP_SAVED_RIGHT"
            zle && zle .reset-prompt
        }
        zle -N _starship_transient_prompt

        autoload -Uz add-zle-hook-widget
        add-zle-hook-widget zle-line-finish _starship_transient_prompt

        function clear-screen {
            _starship_precmd
            zle .clear-screen
        }
        zle -N clear-screen
    fi

    # ── Merged precmd ─────────────────────────────────────────────────────────────
    if [[ -n "${STARSHIP_TRANS_LEFT+1}" || -n "${STARSHIP_TRANS_RIGHT+1}" || -n "${STARSHIP_ASYNC_LEFT+1}" || -n "${STARSHIP_ASYNC_RIGHT+1}" ]]; then

        function _starship_precmd {
            prompt_starship_precmd 2>/dev/null  # capture STARSHIP_CMD_STATUS, STARSHIP_DURATION, STARSHIP_PIPE_STATUS, STARSHIP_JOBS_COUNT

            # ── Transient block ───────────────────────────────────────────────────
            if [[ -n "${STARSHIP_TRANS_LEFT+1}" || -n "${STARSHIP_TRANS_RIGHT+1}" ]]; then
                _STARSHIP_LAST_EXIT=${STARSHIP_CMD_STATUS:-0}

                if [[ -n "${STARSHIP_TRANS_LEFT+1}" ]]; then
                    local profile_args=()
                    [[ $STARSHIP_TRANS_LEFT != DEFAULT ]] && profile_args=(--profile "$STARSHIP_TRANS_LEFT")
                    _STARSHIP_SAVED_LEFT="$(starship prompt "${profile_args[@]}" --status="$_STARSHIP_LAST_EXIT" --terminal-width="$COLUMNS")"
                fi

                if [[ -n "${STARSHIP_TRANS_RIGHT+1}" ]]; then
                    local profile_args=()
                    if [[ $STARSHIP_TRANS_RIGHT == DEFAULT ]]; then
                        profile_args=(--right)
                    else
                        profile_args=(--profile "$STARSHIP_TRANS_RIGHT")
                    fi
                    _STARSHIP_SAVED_RIGHT="$(starship prompt "${profile_args[@]}" --status="$_STARSHIP_LAST_EXIT" --cmd-duration="${STARSHIP_DURATION:-}" --terminal-width="$COLUMNS")"
                fi

                TRAPINT() { _starship_transient_prompt 2>/dev/null; return $(( 128 + $1 )) }
            fi

            # ── Async block ───────────────────────────────────────────────────────
            if [[ -n "${STARSHIP_ASYNC_LEFT+1}" || -n "${STARSHIP_ASYNC_RIGHT+1}" ]]; then
                if [[ -n "${STARSHIP_ASYNC_LEFT+1}" ]]; then
                    PROMPT='$(_starship_fast_prompt)'
                fi
                if [[ -n "${STARSHIP_ASYNC_RIGHT+1}" ]]; then
                    RPROMPT='$(_starship_fast_rprompt)'
                else
                    RPROMPT=''
                fi
                _STARSHIP_LINE_FINISHED=0

                if (( STARSHIP_ASYNC_GIT_CACHE )); then
                    if [[ $PWD != $_STARSHIP_ASYNC_PWD ]]; then
                        if git -C "$PWD" rev-parse --is-inside-work-tree &>/dev/null; then
                            _STARSHIP_ASYNC_GIT=1
                            _STARSHIP_LEFT_SEGMENT=""
                            _STARSHIP_RIGHT_SEGMENT=""
                        else
                            _STARSHIP_ASYNC_GIT=0
                        fi
                    fi
                    if (( ! _STARSHIP_ASYNC_GIT )); then
                        _STARSHIP_LEFT_SEGMENT=""
                        _STARSHIP_RIGHT_SEGMENT=""
                    fi
                else
                    _STARSHIP_LEFT_SEGMENT=""
                    _STARSHIP_RIGHT_SEGMENT=""
                fi

                _STARSHIP_ASYNC_PWD="$PWD"

                if [[ -n "${STARSHIP_ASYNC_LEFT+1}" ]] && (( ${+functions[async_job]} )); then
                    async_job _starship_left_worker _starship_render_left \
                        "$PWD" "${STARSHIP_CMD_STATUS:-0}" "${STARSHIP_PIPE_STATUS[*]:-}" \
                        "${STARSHIP_DURATION:-}" "${STARSHIP_JOBS_COUNT:-0}" "$COLUMNS" "${KEYMAP:-viins}" 2>/dev/null
                fi

                if [[ -n "${STARSHIP_ASYNC_RIGHT+1}" ]] && (( ${+functions[async_job]} )); then
                    async_job _starship_right_worker _starship_render_right \
                        "${STARSHIP_CMD_STATUS:-0}" "${STARSHIP_PIPE_STATUS[*]:-}" \
                        "${STARSHIP_DURATION:-}" "${STARSHIP_JOBS_COUNT:-0}" "$COLUMNS" "${KEYMAP:-viins}" 2>/dev/null
                fi
            fi
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _starship_precmd
    fi
fi
