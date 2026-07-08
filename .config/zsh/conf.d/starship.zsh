if [[ -o interactive ]] && command -v starship &>/dev/null; then
    # ── Defaults — override by exporting before this file is sourced ──────────
    # STARSHIP_ASYNC_RIGHT / STARSHIP_TRANS_RIGHT unset = disabled
	STARSHIP_ASYNC_LEFT=DEFAULT
	STARSHIP_TRANS_LEFT=left_transient
	STARSHIP_TRANS_RIGHT=right_transient

    export STARSHIP_LOG=error
    eval "$(starship init zsh)"

    # ── Transient prompt ──────────────────────────────────────────────────────
    # STARSHIP_TRANS_LEFT / STARSHIP_TRANS_RIGHT: unset=disabled, DEFAULT=no profile
    # (left) or --right (right), any other value=--profile <value>
    if [[ -n "${STARSHIP_TRANS_LEFT+1}" || -n "${STARSHIP_TRANS_RIGHT+1}" ]]; then
        typeset -gi _STARSHIP_LAST_EXIT=0
        typeset -gi _STARSHIP_LINE_FINISHED=0

        function _starship_transient_precmd {
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
        }

        function _starship_transient_prompt() {
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

        function clear-screen() {
            _starship_transient_precmd
            zle .clear-screen
        }
        zle -N clear-screen

        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _starship_transient_precmd
    fi

    # ── Async subsystem ───────────────────────────────────────────────────────
    # STARSHIP_ASYNC_LEFT / STARSHIP_ASYNC_RIGHT: unset=disabled, DEFAULT=no profile
    # (left) or --right (right), any other value=--profile <value>
    if [[ -n "${STARSHIP_ASYNC_LEFT+1}" || -n "${STARSHIP_ASYNC_RIGHT+1}" ]]; then
        # ── zsh-async bootstrap ───────────────────────────────────────────────
        local async_zsh="${ZIM_HOME:-${ZDOTDIR:-${HOME}}/.zim}/modules/zsh-async/async.zsh"
        [[ -f $async_zsh ]] && source "$async_zsh"
        unset async_zsh

        # ── State ─────────────────────────────────────────────────────────────
        typeset -g  _STARSHIP_ASYNC_PWD=""
        typeset -gi _STARSHIP_LINE_FINISHED=0
        typeset -g  _STARSHIP_LEFT_SEGMENT=""
        typeset -g  _STARSHIP_RIGHT_SEGMENT=""

        # ── PROMPT_SUBST ──────────────────────────────────────────────────────
        setopt PROMPT_SUBST

        if [[ -n "${STARSHIP_ASYNC_LEFT+1}" ]]; then
            PROMPT='$(_starship_native_prompt)'
        fi

        # RPROMPT: use async right worker if configured, otherwise empty
        # (time comes from starship's own format rendered in the left segment)
        if [[ -n "${STARSHIP_ASYNC_RIGHT+1}" ]]; then
            RPROMPT='$(_starship_native_rprompt)'

            function _starship_native_rprompt {
                if [[ -n $_STARSHIP_RIGHT_SEGMENT ]]; then
                    print -rn -- "$_STARSHIP_RIGHT_SEGMENT"
                else
                    print -Pn -- "%F{#8d8d8d}%D{%H:%M:%S}%f"
                fi
            }
        else
            RPROMPT=''
        fi

        # ── Job functions ─────────────────────────────────────────────────────
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

        # ── Persistent workers ────────────────────────────────────────────────
        if [[ -n "${STARSHIP_ASYNC_LEFT+1}" ]] && (( ${+functions[async_start_worker]} )); then
            async_start_worker _starship_left_worker -u
            async_register_callback _starship_left_worker _starship_left_callback
        fi

        if [[ -n "${STARSHIP_ASYNC_RIGHT+1}" ]] && (( ${+functions[async_start_worker]} )); then
            async_start_worker _starship_right_worker -u
            async_register_callback _starship_right_worker _starship_right_callback
        fi

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

        # ── Async precmd hook ─────────────────────────────────────────────────
        function _starship_async_precmd {
            if [[ -n "${STARSHIP_ASYNC_LEFT+1}" ]]; then
                PROMPT='$(_starship_native_prompt)'
            fi
            if [[ -n "${STARSHIP_ASYNC_RIGHT+1}" ]]; then
                RPROMPT='$(_starship_native_rprompt)'
            else
                RPROMPT=''
            fi
            _STARSHIP_LINE_FINISHED=0
            _STARSHIP_LEFT_SEGMENT=""
            _STARSHIP_RIGHT_SEGMENT=""

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
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _starship_async_precmd
    fi
fi
