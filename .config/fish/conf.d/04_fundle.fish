if status is-interactive
    if not functions -q fundle
        eval (curl -sfL https://git.io/fundle-install)
        set -q __fundle_install; or set __fundle_install true
    end

    if functions -q fundle
        fundle plugin danhper/fundle
        fundle plugin tuvistavie/fish-completion-helpers
        fundle plugin jorgebucaran/autopair.fish
        fundle plugin nickeb96/puffer-fish
        fundle plugin acomagu/fish-async-prompt

        set -x async_prompt_functions 'starship prompt' 'starship prompt --right'

        function fish_right_prompt_loading_indicator -a last_prompt
            echo -n "$last_prompt" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g' | read -zl uncolored_last_prompt
            echo -n (set_color brblack)"$uncolored_last_prompt"(set_color normal)
        end

        if fundle init 2>&1 | command grep -qF 'not installed'
            set -q __fundle_install; or set __fundle_install true
        end

        if test "$__fundle_install" = true
            set -x __fundle_install false
            fundle install
            exec fish
        end
    end
end
