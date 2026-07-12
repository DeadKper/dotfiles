if [[ -o interactive ]] && command -v starship &>/dev/null; then
    if ! (( "$STARSHIP_SOURCED" )); then
        # ── Defaults ──────────────────────────────────────────────────────────────────
        STARSHIP_SOURCED=1

        STARSHIP_FAST_LEFT=fast_left
        STARSHIP_FAST_RIGHT=''

        STARSHIP_TRANS_LEFT=transient_left
        STARSHIP_TRANS_RIGHT=transient_right

        STARSHIP_GIT_CACHE_ENABLED=1
        STARSHIP_ASYNC_LEFT=DEFAULT
        STARSHIP_ASYNC_RIGHT=''

        export STARSHIP_LOG=error

        # ── Fast profile prompts ───────────────────────────────────────────────────
        function _starship_fast_prompt {
            if [[ -n "$_STARSHIP_SEGMENT_LEFT" ]]; then
                print -rn -- "${_STARSHIP_SEGMENT_LEFT}"
            else
                starship prompt --profile $STARSHIP_FAST_LEFT --status="${_STARSHIP_LAST_EXIT:-0}"
            fi
        }

        function _starship_fast_rprompt {
            if [[ -n "$_STARSHIP_SEGMENT_RIGHT" ]]; then
                print -rn -- "$_STARSHIP_SEGMENT_RIGHT"
            else
                starship prompt --profile $STARSHIP_FAST_RIGHT --status="${_STARSHIP_LAST_EXIT:-0}"
            fi
        }
    fi

    # ── Phase guard: instant prompt only ─────────────────────────────────────────
    if [[ ${1:-} == instant ]]; then
        function _starship_instant_prompt {
            print -n $'\e7'

            print -Pn -- "$(_starship_fast_prompt)"

            (( ${COLUMNS:-0} > 0 )) && print -n $'\e[3G'
            unsetopt prompt_cr prompt_sp

            function _starship_instant_prompt_cleanup {
                print -n $'\e[?25l\e8\e[J\e[?25h'
                unfunction _starship_instant_prompt_cleanup
            }

            function _starship_instant_prompt_precmd {
                function _starship_instant_prompt_sched_last {
                    (( ${+functions[_starship_instant_prompt_cleanup]} )) || return
                    _starship_instant_prompt_cleanup
                    setopt no_local_options prompt_cr prompt_sp
                }
                zmodload zsh/sched
                sched +0 _starship_instant_prompt_sched_last
                precmd_functions=("${(@)precmd_functions:#_starship_instant_prompt_precmd}")
            }

            precmd_functions=(_starship_instant_prompt_precmd "${precmd_functions[@]}")
        }

        return 0
    fi

    # ── Feature flags ─────────────────────────────────────────────────────────────
    [[ -n "$STARSHIP_FAST_LEFT" && -n "$STARSHIP_ASYNC_LEFT" ]] && _STARSHIP_ASYNC_LEFT_ENABLED=1
    [[ -n "$STARSHIP_FAST_RIGHT" && -n "$STARSHIP_ASYNC_RIGHT" ]] && _STARSHIP_ASYNC_RIGHT_ENABLED=1

    [[ -n "$_STARSHIP_ASYNC_LEFT_ENABLED$_STARSHIP_ASYNC_RIGHT_ENABLED" ]] && _STARSHIP_ASYNC_ENABLED=1
    [[ -n "$STARSHIP_TRANS_LEFT$STARSHIP_TRANS_RIGHT" ]] && _STARSHIP_TRANS_ENABLED=1

    [[ -n "$_STARSHIP_ASYNC_ENABLED$_STARSHIP_TRANS_ENABLED" ]] && _STARSHIP_CUSTOM_ENABLED=1

    # ── Starship init interception ────────────────────────────────────────────────
    # Strip PROMPT/RPROMPT/PROMPT2 assignments and starship's own precmd hook.
    # prompt_starship_precmd still gets defined (captures STARSHIP_CMD_STATUS etc.).
    # preexec hook still registers (timing). We own precmd entirely via _starship_precmd.
    if (( _STARSHIP_CUSTOM_ENABLED )); then
        eval "$(starship init zsh | sed '/^PROMPT=/d; /^RPROMPT=/d; /^PROMPT2=/d; /add-zsh-hook precmd prompt_starship_precmd/d')"
    else
        eval "$(starship init zsh)"
    fi

    # ── Transient state ───────────────────────────────────────────────────────────
    typeset -gi _STARSHIP_LAST_EXIT=0
    typeset -gi _STARSHIP_LINE_FINISHED=0
    typeset -g  _STARSHIP_SAVED_LEFT=""
    typeset -g  _STARSHIP_SAVED_RIGHT=""
    typeset -g  _STARSHIP_SAVED_PWD=""

    # ── Async state ───────────────────────────────────────────────────────────────
    typeset -g  _STARSHIP_ASYNC_PWD=""
    typeset -g  _STARSHIP_SEGMENT_LEFT=""
    typeset -g  _STARSHIP_SEGMENT_RIGHT=""
    typeset -gi _STARSHIP_ASYNC_GIT_ENABLED=0

    setopt PROMPT_SUBST

    # ── zsh-async bootstrap ───────────────────────────────────────────────────────
    local async_zsh="${ZIM_HOME:-${ZDOTDIR:-${HOME}}/.zim}/modules/zsh-async/async.zsh"
    [[ -f $async_zsh ]] && source "$async_zsh"
    unset async_zsh

    # ── Async job functions ───────────────────────────────────────────────────────
    function _starship_render_left {
        cd "$1" 2>/dev/null || return 1
        local profile_args=()
        [[ "$STARSHIP_ASYNC_LEFT" != DEFAULT ]] && profile_args=(--profile "$STARSHIP_ASYNC_LEFT")
        starship prompt "${profile_args[@]}" --status="$2" --pipestatus="$3" \
            --cmd-duration="$4" --jobs="$5" --terminal-width="$6" --keymap="$7"
    }

    function _starship_render_right {
        local profile_args=()
        if [[ "$STARSHIP_ASYNC_RIGHT" != DEFAULT ]]; then
            profile_args=(--profile "$STARSHIP_ASYNC_RIGHT")
        else
            profile_args=(--right)
        fi
        starship prompt "${profile_args[@]}" --status="$1" --pipestatus="$2" \
            --cmd-duration="$3" --jobs="$4" --terminal-width="$5" --keymap="$6"
    }

    # ── Persistent async workers ──────────────────────────────────────────────────
    if [[ -n "$STARSHIP_ASYNC_LEFT" ]] && (( ${+functions[async_start_worker]} )); then
        async_start_worker _starship_worker_left -u
        async_register_callback _starship_worker_left _starship_callback_left
    fi

    if [[ -n "$STARSHIP_ASYNC_RIGHT" ]] && (( ${+functions[async_start_worker]} )); then
        async_start_worker _starship_worker_right -u
        async_register_callback _starship_worker_right _starship_callback_right
    fi

    # ── Async callbacks ───────────────────────────────────────────────────────────
    function _starship_callback_left {
        local job=$1 ret=$2 stdout=$3 exec_time=$4 stderr=$5 has_next=$6
        [[ "$job" == '[async]' ]] && return
        [[ "$PWD" != "$_STARSHIP_ASYNC_PWD" ]] && return
        (( has_next )) && return
        if (( ! _STARSHIP_LINE_FINISHED )) && zle && [[ $ret -eq 0 ]]; then
            _STARSHIP_SEGMENT_LEFT="$stdout"
            zle reset-prompt
        fi
    }

    function _starship_callback_right {
        local job=$1 ret=$2 stdout=$3 exec_time=$4 stderr=$5 has_next=$6
        [[ "$job" == '[async]' ]] && return
        [[ "$PWD" != "$_STARSHIP_ASYNC_PWD" ]] && return
        (( has_next )) && return
        if (( ! _STARSHIP_LINE_FINISHED )) && zle && [[ $ret -eq 0 ]]; then
            _STARSHIP_SEGMENT_RIGHT="$stdout"
            zle reset-prompt
        fi
    }

    # ── Transient prompt ──────────────────────────────────────────────────────────
    if (( _STARSHIP_TRANS_ENABLED )); then
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
    if (( _STARSHIP_CUSTOM_ENABLED )); then

        function _starship_precmd {
            prompt_starship_precmd 2>/dev/null  # capture STARSHIP_CMD_STATUS, STARSHIP_DURATION, STARSHIP_PIPE_STATUS, STARSHIP_JOBS_COUNT

            # ── Transient block ───────────────────────────────────────────────────
            if (( _STARSHIP_TRANS_ENABLED )); then
                _STARSHIP_LAST_EXIT=${STARSHIP_CMD_STATUS:-0}

                if [[ -n "$STARSHIP_TRANS_LEFT" ]]; then
                    local profile_args=()
                    [[ "$STARSHIP_TRANS_LEFT" != DEFAULT ]] && profile_args=(--profile "$STARSHIP_TRANS_LEFT")
                    _STARSHIP_SAVED_LEFT="$(starship prompt "${profile_args[@]}" --status="$_STARSHIP_LAST_EXIT" --terminal-width="$COLUMNS")"
                fi

                if [[ -n "$STARSHIP_TRANS_RIGHT" ]]; then
                    local profile_args=()
                    if [[ "$STARSHIP_TRANS_RIGHT" != DEFAULT ]]; then
                        profile_args=(--profile "$STARSHIP_TRANS_RIGHT")
                    else
                        profile_args=(--right)
                    fi
                    _STARSHIP_SAVED_RIGHT="$(starship prompt "${profile_args[@]}" --status="$_STARSHIP_LAST_EXIT" --cmd-duration="${STARSHIP_DURATION:-}" --terminal-width="$COLUMNS")"
                fi

                TRAPINT() { _starship_transient_prompt 2>/dev/null; return $(( 128 + $1 )) }
            fi

            # ── Async block ───────────────────────────────────────────────────────
            if (( _STARSHIP_ASYNC_ENABLED )); then
                if (( _STARSHIP_ASYNC_LEFT_ENABLED )); then
                    PROMPT='$(_starship_fast_prompt)'
                fi
                if (( _STARSHIP_ASYNC_RIGHT_ENABLED )); then
                    RPROMPT='$(_starship_fast_rprompt)'
                else
                    RPROMPT=''
                fi
                _STARSHIP_LINE_FINISHED=0

                if (( STARSHIP_GIT_CACHE_ENABLED )); then
                    if [[ "$PWD" != "$_STARSHIP_ASYNC_PWD" ]]; then
                        if git -C "$PWD" rev-parse --is-inside-work-tree &>/dev/null; then
                            _STARSHIP_ASYNC_GIT_ENABLED=1
                            _STARSHIP_SEGMENT_LEFT=""
                            _STARSHIP_SEGMENT_RIGHT=""
                        else
                            _STARSHIP_ASYNC_GIT_ENABLED=0
                        fi
                    fi
                    if (( ! _STARSHIP_ASYNC_GIT_ENABLED )); then
                        _STARSHIP_SEGMENT_LEFT=""
                        _STARSHIP_SEGMENT_RIGHT=""
                    fi
                else
                    _STARSHIP_SEGMENT_LEFT=""
                    _STARSHIP_SEGMENT_RIGHT=""
                fi

                _STARSHIP_ASYNC_PWD="$PWD"

                if (( _STARSHIP_ASYNC_LEFT_ENABLED )) && (( ${+functions[async_job]} )); then
                    async_job _starship_worker_left _starship_render_left \
                        "$PWD" "${STARSHIP_CMD_STATUS:-0}" "${STARSHIP_PIPE_STATUS[*]:-}" \
                        "${STARSHIP_DURATION:-}" "${STARSHIP_JOBS_COUNT:-0}" "$COLUMNS" "${KEYMAP:-viins}" 2>/dev/null
                fi

                if (( _STARSHIP_ASYNC_RIGHT_ENABLED )) && (( ${+functions[async_job]} )); then
                    async_job _starship_worker_right _starship_render_right \
                        "${STARSHIP_CMD_STATUS:-0}" "${STARSHIP_PIPE_STATUS[*]:-}" \
                        "${STARSHIP_DURATION:-}" "${STARSHIP_JOBS_COUNT:-0}" "$COLUMNS" "${KEYMAP:-viins}" 2>/dev/null
                fi
            fi
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _starship_precmd
    fi
fi
