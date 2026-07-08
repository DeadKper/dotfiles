if [[ -o interactive ]] && command -v starship &>/dev/null; then
    export STARSHIP_LOG=error
    eval "$(starship init zsh)"

    # ── Profile detection — runs once at init ─────────────────────────────────
    profiles=$(starship print-config 2>/dev/null | awk '/^\[profiles\]/{p=1;next} p && /^\[/{p=0} p && /^[a-z]/{print $1}')

    typeset -gi _has_left_async=0 _has_left_trans=0 _has_right_trans=0
    [[ $profiles == *$'\n'left_async*      || $profiles == left_async*      ]] && _has_left_async=1
    [[ $profiles == *$'\n'left_transient*  || $profiles == left_transient*  ]] && _has_left_trans=1
    [[ $profiles == *$'\n'right_transient* || $profiles == right_transient* ]] && _has_right_trans=1

    has_transient=$(( _has_left_trans || _has_right_trans ))

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
    if (( _has_left_async )); then
        # ── zsh-async bootstrap ───────────────────────────────────────────────
        local async_zsh="${ZIM_HOME:-${ZDOTDIR:-${HOME}}/.zim}/modules/zsh-async/async.zsh"
        [[ -f $async_zsh ]] && source "$async_zsh"
        unset async_zsh

        # ── State ─────────────────────────────────────────────────────────────
        typeset -g  _STARSHIP_ASYNC_PWD=""
        typeset -gi _STARSHIP_LINE_FINISHED=0   # shared with transient if both active
        typeset -g  _STARSHIP_LEFT_SEGMENT=""   # async-rendered dir line (empty = show native placeholder)

        # ── PROMPT_SUBST ──────────────────────────────────────────────────────
        setopt PROMPT_SUBST

        PROMPT='$(_starship_native_prompt)'
        RPROMPT=''

        # ── Job function — default profile renders full prompt ────────────────
        function _starship_render_left {
            cd "$1" 2>/dev/null || return 1
            starship prompt --status="$2" --pipestatus="$3" --cmd-duration="$4" \
                --jobs="$5" --terminal-width="$6" --keymap="$7"
        }

        # ── Persistent worker ─────────────────────────────────────────────────
        if (( ${+functions[async_start_worker]} )); then
            async_start_worker _starship_left_worker -u
            async_register_callback _starship_left_worker _starship_left_callback
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

        # ── Async precmd hook ─────────────────────────────────────────────────
        function _starship_async_precmd {
            PROMPT='$(_starship_native_prompt)'
            RPROMPT=''
            _STARSHIP_LINE_FINISHED=0
            _STARSHIP_LEFT_SEGMENT=""

            _STARSHIP_ASYNC_PWD="$PWD"

            if (( ${+functions[async_job]} )); then
                async_job _starship_left_worker _starship_render_left \
                    "$PWD" "${STARSHIP_CMD_STATUS:-0}" "${STARSHIP_PIPE_STATUS[*]:-}" \
                    "${STARSHIP_DURATION:-}" "${STARSHIP_JOBS_COUNT:-0}" "$COLUMNS" "${KEYMAP:-viins}" 2>/dev/null
            fi
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _starship_async_precmd
    fi
fi
