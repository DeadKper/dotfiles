# Bootstrap antigen
PLUGIN="$(dirname "$0")/.antigen.zsh"
test -f "$PLUGIN" || curl -L git.io/antigen > "$PLUGIN"

if test -f "$PLUGIN"; then
	# Load antigen
	source "$PLUGIN"

	# Load the oh-my-zsh's library.
	antigen use oh-my-zsh

	# Bundles from the default repo (robbyrussell's oh-my-zsh).
	antigen bundle command-not-found
	antigen bundle git
	antigen bundle git-flow
	antigen bundle history
	antigen bundle npm
	antigen bundle pip
	antigen bundle python
	antigen bundle rsync

	antigen bundle zsh-users/zsh-autosuggestions
	antigen bundle zsh-users/zsh-completions src
	antigen bundle zsh-users/zsh-history-substring-search ./zsh-history-substring-search.zsh
	antigen bundle zsh-users/zsh-syntax-highlighting

	antigen bundle olets/zsh-abbr@main
	antigen bundle hlissner/zsh-autopair

	antigen theme romkatv/powerlevel10k

	antigen apply
fi
