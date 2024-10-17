# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTSIZE=5000
SAVEHIST=100000
setopt autocd extendedglob
unsetopt beep
bindkey -e

zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit && compinit

local ZSH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# To customize prompt, run `p10k configure` or edit $ZSH_CONFIG/conf.d/p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || mv ~/.p10k.zsh "$ZSH_CONFIG/conf.d/p10k.zsh"

# Load plugins
source "$ZSH_CONFIG/antigen.zsh"

while read -r file; do
	source "$file"
done < <(find "$ZSH_CONFIG/conf.d" -maxdepth 1 -type f -iname '*.zsh' -print | sort)
