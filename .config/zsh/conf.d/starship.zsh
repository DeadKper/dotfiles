if [[ -o interactive ]] && command -v starship &>/dev/null; then
    if ! (( "$STARSHIP_SOURCED" )); then
        ZLE_RPROMPT_INDENT=0

        # ── Defaults ──────────────────────────────────────────────────────────────────
        STARSHIP_SOURCED=1

        STARSHIP_FAST_LEFT=fast_left
        STARSHIP_FAST_RIGHT=''

        STARSHIP_TRANS_LEFT=transient_left
        STARSHIP_TRANS_RIGHT=transient_right

        STARSHIP_PROMPT2=DEFAULT

        STARSHIP_GIT_CACHE_ENABLED=1
        STARSHIP_ASYNC_LEFT=DEFAULT
        STARSHIP_ASYNC_RIGHT=''

        export STARSHIP_LOG=error

        # ── Fast profile prompts ───────────────────────────────────────────────────
        function _starship_fast_prompt {
            local fast_left="$(starship prompt --profile $STARSHIP_FAST_LEFT \
                --status="${_STARSHIP_LAST_EXIT:-0}" \
                --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" \
                --cmd-duration="${STARSHIP_DURATION:-}" \
                --jobs="${STARSHIP_JOBS_COUNT:-0}" \
                --terminal-width="$COLUMNS" \
                --keymap="${KEYMAP:-viins}")"
            if [[ -n "$_STARSHIP_SEGMENT_LEFT" ]]; then
                local fill_start=$'%{\e[1;30m%}'

                if [[ "$_STARSHIP_SEGMENT_LEFT" == *"$fill_start"* ]]; then
                    local left_cached fast_right fill_str
                    local zero='%([BSUbfksu]|([FK]|){*})'
                    local fill_end=$'%{\e[0m%}'

                    left_cached="${_STARSHIP_SEGMENT_LEFT%%${fill_start}*}"
                    fast_right="${${fast_left#*${fill_start}}#*${fill_end}}"

                    local left_size=${(m)#${(S%%)left_cached//$~zero/}}
                    local right_size=${(m)#${(S%%)${fast_right%%$'\n'*}//$~zero/}}

                    local fill_width=$(( COLUMNS - left_size - right_size ))
                    (( fill_width < 0 )) && fill_width=0
                    printf -v fill_str '%*s' "$fill_width" ''

                    print -rn -- "${left_cached}${fill_str}${fast_right}"
                else
                    print -rn -- "${_STARSHIP_SEGMENT_LEFT}"
                fi
            else
                print -rn -- "$fast_left"
            fi
        }

        function _starship_fast_rprompt {
            if [[ -n "$_STARSHIP_SEGMENT_RIGHT" ]]; then
                print -rn -- "$_STARSHIP_SEGMENT_RIGHT"
            else
                starship prompt --profile $STARSHIP_FAST_RIGHT \
                    --status="${_STARSHIP_LAST_EXIT:-0}" \
                    --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" \
                    --cmd-duration="${STARSHIP_DURATION:-}" \
                    --jobs="${STARSHIP_JOBS_COUNT:-0}" \
                    --terminal-width="$COLUMNS" \
                    --keymap="${KEYMAP:-viins}"
            fi
        }
    fi

    # ── Phase guard: instant prompt only ─────────────────────────────────────────
    if [[ ${1:-} == instant ]]; then
        function _starship_instant_prompt {
            print -n $'\e7'

            print -Pn -- "$(_starship_fast_prompt)"

            if [[ -n "$STARSHIP_FAST_RIGHT" ]]; then
                local rp_rendered rp_plain rp_col
                rp_rendered="$(_starship_fast_rprompt)"
                rp_plain="$(print -P -- "$rp_rendered" | sed 's/\x1b\[[0-9;]*[A-Za-z]//g')"
                rp_col=$(( COLUMNS - ${#rp_plain} + 1 ))
                (( rp_col > 0 )) && {
                    print -n $'\e[s'
                    print -n "\e[${rp_col}G"
                    print -Pn -- "$rp_rendered"
                    print -n $'\e[u'
                }
            fi

            print -n ''
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

    # ── PROMPT2 ───────────────────────────────────────────────────────────────────
    if [[ -n "$STARSHIP_PROMPT2" ]]; then
        if [[ "$STARSHIP_PROMPT2" == DEFAULT ]]; then
            PROMPT2='$(starship prompt --continuation)'
        else
            PROMPT2='$(starship prompt --profile "$STARSHIP_PROMPT2")'
        fi
    fi

    # ── Transient state ───────────────────────────────────────────────────────────
    typeset -gi _STARSHIP_LAST_EXIT=0
    typeset -gi _STARSHIP_LINE_FINISHED=0
    typeset -g  _STARSHIP_TRANS_PROMPT=""
    typeset -g  _STARSHIP_TRANS_RPROMPT=""
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

    # ── Async job function ────────────────────────────────────────────────────────
    function _starship_async_render {
        local side=$1 profile=$2; shift 2
        cd "$1" 2>/dev/null || return 1
        local profile_args=()
        if [[ "$profile" == DEFAULT ]]; then
            [[ "$side" == right ]] && profile_args=(--right)
        else
            [[ -n "$profile" ]] && profile_args=(--profile "$profile")
        fi
        starship prompt "${profile_args[@]}" --status="$2" --pipestatus="$3" \
            --cmd-duration="$4" --jobs="$5" --terminal-width="$6" --keymap="$7"
    }

    # ── Async callbacks + worker registration ─────────────────────────────────────
    function _starship_async_callback {
        local side=$1 job=$2 ret=$3 stdout=$4 has_next=$7
        [[ "$job" == '[async]' ]] && return
        [[ "$PWD" != "$_STARSHIP_ASYNC_PWD" ]] && return
        (( has_next )) && return
        if (( ! _STARSHIP_LINE_FINISHED )) && zle && [[ $ret -eq 0 ]]; then
            typeset -g "_STARSHIP_SEGMENT_${side:u}=$stdout"
            if (( _STARSHIP_TRANS_ENABLED )); then
                local _trans_args=(
                    --status="$_STARSHIP_LAST_EXIT"
                    --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}"
                    --cmd-duration="${STARSHIP_DURATION:-}"
                    --jobs="${STARSHIP_JOBS_COUNT:-0}"
                    --terminal-width="$COLUMNS"
                    --keymap="${KEYMAP:-viins}"
                )
                [[ -n "$STARSHIP_TRANS_LEFT" ]]  && _STARSHIP_TRANS_PROMPT="$(starship prompt --profile "$STARSHIP_TRANS_LEFT" "${_trans_args[@]}")"
                [[ -n "$STARSHIP_TRANS_RIGHT" ]] && _STARSHIP_TRANS_RPROMPT="$(starship prompt --profile "$STARSHIP_TRANS_RIGHT" "${_trans_args[@]}")"
            fi
            zle reset-prompt
        fi
    }

    local side profile_var
    for side in left right; do
        profile_var="STARSHIP_ASYNC_${side:u}"
        eval "function _starship_async_callback_${side} { _starship_async_callback ${side} \"\$@\" }"
        if [[ -n "${(P)profile_var}" ]] && (( ${+functions[async_start_worker]} )); then
            async_start_worker _starship_async_worker_${side} -u
            async_register_callback _starship_async_worker_${side} _starship_async_callback_${side}
        fi
    done
    unset side profile_var

    # ── Transient prompt ──────────────────────────────────────────────────────────
    if (( _STARSHIP_TRANS_ENABLED )); then
        function _starship_transient_prompt {
            _STARSHIP_LINE_FINISHED=1
            if [[ "$PWD" != "$_STARSHIP_SAVED_PWD" ]]; then
                _STARSHIP_SAVED_PWD="$PWD"
                return
            fi
            _STARSHIP_SAVED_PROMPT="$PROMPT" _STARSHIP_SAVED_RPROMPT="$RPROMPT"
            PROMPT="$_STARSHIP_TRANS_PROMPT" RPROMPT="$_STARSHIP_TRANS_RPROMPT"
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

                local side trans_var profile_var profile profile_args=() args=(
                    --status="$_STARSHIP_LAST_EXIT"
                    --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}"
                    --cmd-duration="${STARSHIP_DURATION:-}"
                    --jobs="${STARSHIP_JOBS_COUNT:-0}"
                    --terminal-width="$COLUMNS"
                    --keymap="${KEYMAP:-viins}"
                )
                for side in left right; do
                    trans_var="STARSHIP_TRANS_${side:u}"
                    profile="${(P)trans_var}"
                    [[ -z "$profile" ]] && continue

                    if [[ "$side" == left ]]; then
                        [[ -n "$profile" ]] && profile_args=(--profile "$profile")
                        PROMPT="$_STARSHIP_SAVED_PROMPT"
                        _STARSHIP_TRANS_PROMPT="$(starship prompt "${profile_args[@]}" "${args[@]}")"
                    else
                        if [[ -n "$profile" ]]; then
                            profile_args=(--profile "$profile")
                        else
                            profile_args=(--right)
                        fi
                        RPROMPT="$_STARSHIP_SAVED_RPROMPT"
                        _STARSHIP_TRANS_RPROMPT="$(starship prompt "${profile_args[@]}" "${args[@]}")"
                    fi
                done

                TRAPINT() { _starship_transient_prompt 2>/dev/null; return $(( 128 + $1 )) }
            fi

            # ── Async block ───────────────────────────────────────────────────────
            if (( _STARSHIP_ASYNC_ENABLED )); then
                (( _STARSHIP_ASYNC_LEFT_ENABLED )) && PROMPT='$(_starship_fast_prompt)'
                (( _STARSHIP_ASYNC_RIGHT_ENABLED )) && RPROMPT='$(_starship_fast_rprompt)'

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

                local args=(
                    "$PWD"
                    "${STARSHIP_CMD_STATUS:-0}"
                    "${STARSHIP_PIPE_STATUS[*]:-}"
                    "${STARSHIP_DURATION:-}"
                    "${STARSHIP_JOBS_COUNT:-0}"
                    "$COLUMNS"
                    "${KEYMAP:-viins}"
                )
                (( _STARSHIP_ASYNC_LEFT_ENABLED )) && (( ${+functions[async_job]} )) && \
                    async_job _starship_async_worker_left _starship_async_render left "$STARSHIP_ASYNC_LEFT" "${args[@]}" 2>/dev/null
                (( _STARSHIP_ASYNC_RIGHT_ENABLED )) && (( ${+functions[async_job]} )) && \
                    async_job _starship_async_worker_right _starship_async_render right "$STARSHIP_ASYNC_RIGHT" "${args[@]}" 2>/dev/null
            fi
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _starship_precmd
    fi
fi
