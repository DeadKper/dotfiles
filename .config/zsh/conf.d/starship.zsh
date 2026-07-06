if [[ -o interactive ]] && command -v starship &>/dev/null; then
    export STARSHIP_LOG=error
    eval "$(starship init zsh)"

    # ── Profile detection — runs once at init ─────────────────────────────────
    local profiles
    profiles=$(starship print-config 2>/dev/null | awk '/^\[profiles\]/{p=1;next} p && /^\[/{p=0} p && /^[a-z]/{print $1}')

    typeset -gi _has_left_async=0 _has_right_async=0 _has_left_trans=0 _has_right_trans=0
    [[ $profiles == *$'\n'left_async*      || $profiles == left_async*      ]] && _has_left_async=1
    [[ $profiles == *$'\n'right_async*     || $profiles == right_async*     ]] && _has_right_async=1
    [[ $profiles == *$'\n'left_transient*  || $profiles == left_transient*  ]] && _has_left_trans=1
    [[ $profiles == *$'\n'right_transient* || $profiles == right_transient* ]] && _has_right_trans=1

    local has_async=$(( _has_left_async || _has_right_async ))
    local has_transient=$(( _has_left_trans || _has_right_trans ))

    # ── Transient prompt ──────────────────────────────────────────────────────
    if (( has_transient )); then
        typeset -gi _STARSHIP_LAST_EXIT=0
        typeset -gi _STARSHIP_LINE_FINISHED=0

        function _starship_transient_precmd {
            _STARSHIP_LAST_EXIT=${STARSHIP_CMD_STATUS:-0}
            if (( _has_left_trans )); then
                _STARSHIP_SAVED_LEFT="$(starship prompt --profile left_transient --status="$_STARSHIP_LAST_EXIT" --terminal-width="$COLUMNS")"
            fi
            if (( _has_right_trans )); then
                _STARSHIP_SAVED_RIGHT="$(starship prompt --profile right_transient --status="$_STARSHIP_LAST_EXIT" --cmd-duration="${STARSHIP_DURATION:-}" --terminal-width="$COLUMNS")"
            elif (( _has_right_async )); then
                _STARSHIP_SAVED_RIGHT="$(starship prompt --profile right_async --status="$_STARSHIP_LAST_EXIT" --cmd-duration="${STARSHIP_DURATION:-}" --terminal-width="$COLUMNS")"
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
    if (( has_async )); then
        # ── zsh-async bootstrap ───────────────────────────────────────────────
        local async_zsh="${ZDOTDIR}/.zim/modules/zsh-async/async.zsh"
        [[ -f $async_zsh ]] && source "$async_zsh"
        unset async_zsh

        # ── State ─────────────────────────────────────────────────────────────
        typeset -g  _STARSHIP_ASYNC_PWD=""
        typeset -gi _STARSHIP_LINE_FINISHED=0   # shared with transient if both active
        typeset -g  _STARSHIP_LEFT_SEGMENT=""   # async-rendered line 1 (empty = show native placeholder)
        typeset -g  _STARSHIP_RIGHT_SEGMENT=""  # async right render

        # ── PROMPT_SUBST native prompts ──────────────────────────────────────
        setopt PROMPT_SUBST

        # Left: full starship line when async ready, native placeholder until then.
        function _starship_native_prompt {
            local char
            if (( ${_STARSHIP_LAST_EXIT:-0} )); then
                char="%B%F{#ee5396}❯%b%f "
            else
                char="%B%F{#be95ff}❯%b%f "
            fi
            if [[ -n $_STARSHIP_LEFT_SEGMENT ]]; then
                print -rn -- "${_STARSHIP_LEFT_SEGMENT}"$'\n'"${char}"
            else
                print -rn -- "%F{#e0e0e0}zsh%f %F{#78a9ff}%(6~|%-1~/…/%4~|%~)%f"$'\n'"${char}"
            fi
        }

        # Right: async render when ready, native time-only fallback.
        function _starship_native_rprompt {
            if [[ -n $_STARSHIP_RIGHT_SEGMENT ]]; then
                print -rn -- "$_STARSHIP_RIGHT_SEGMENT"
            else
                print -rn -- "%F{#8d8d8d}%D{%H:%M:%S}%f"
            fi
        }

        PROMPT='$(_starship_native_prompt)'
        RPROMPT='$(_starship_native_rprompt)'

        # ── Job functions — defined before workers fork ───────────────────────
        function _starship_render_left {
            cd "$1" 2>/dev/null || return 1
            starship prompt --profile left_async --terminal-width="$2"
        }

        function _starship_render_right {
            starship prompt --profile right_async \
                --status="$1" --pipestatus="$2" --cmd-duration="$3" \
                --jobs="$4" --terminal-width="$5" --keymap="$6"
        }

        # ── Persistent workers ────────────────────────────────────────────────
        if (( _has_left_async )); then
            async_start_worker _starship_left_worker -u
            async_register_callback _starship_left_worker _starship_left_callback
        fi

        if (( _has_right_async )); then
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
            PROMPT='$(_starship_native_prompt)'
            RPROMPT='$(_starship_native_rprompt)'
            _STARSHIP_LINE_FINISHED=0
            if [[ $PWD != $_STARSHIP_ASYNC_PWD ]]; then
                _STARSHIP_LEFT_SEGMENT=""
            fi
            _STARSHIP_RIGHT_SEGMENT=""

            _STARSHIP_ASYNC_PWD="$PWD"

            if (( _has_left_async )); then
                async_flush_jobs _starship_left_worker
                async_job _starship_left_worker _starship_render_left "$PWD" "$COLUMNS"
            fi

            if (( _has_right_async )); then
                async_flush_jobs _starship_right_worker
                async_job _starship_right_worker _starship_render_right \
                    "${STARSHIP_CMD_STATUS:-0}" "${STARSHIP_PIPE_STATUS[*]:-}" "${STARSHIP_DURATION:-}" "${STARSHIP_JOBS_COUNT:-0}" "$COLUMNS" "${KEYMAP:-viins}"
            fi
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _starship_async_precmd
    fi
fi
