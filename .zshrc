local XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

local XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
test -d "$XDG_STATE_HOME" || mkdir -p "$XDG_STATE_HOME"

HISTFILE="$XDG_STATE_HOME/zsh_history"
HISTSIZE=5000
SAVEHIST=100000

setopt autocd extendedglob
unsetopt beep

bindkey -e

local ZSH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

[[ ! -f ~/.p10k.zsh ]] || mv ~/.p10k.zsh "$ZSH_CONFIG/conf.d/p10k.zsh"

source "$ZSH_CONFIG/antigen.zsh"

while read -r file; do
	source "$file"
done < <(find "$ZSH_CONFIG/conf.d" -maxdepth 1 -type f -iname '*.zsh' -print | sort)
