if test -z "$ENV_SET"
	# Add to path
	fish_add_path "$HOME/.local/bin"
	fish_add_path "$HOME/.surrealdb"

	# Configure variables
	set fish_greeting
	set -xg EDITOR nvim
	set -xg VISUAL nvim
	set -xg NIXPKGS_ALLOW_UNFREE 1
	if type -q setxkbmap
		set -xg XKB_DEFAULT_LAYOUT (setxkbmap -query | grep layout | sed -r "s/^layout:\t* *(.*)/\1/g")
		set -xg XKB_DEFAULT_VARIANT (setxkbmap -query | grep variant | sed -r "s/^variant:\t* *(.*)/\1/g")
	end
end

# Set XDG variables if not set
if test -z "$XDG_CONFIG_HOME"
	if not test -f "$HOME/.config/user-dirs.dirs"
		xdg-user-dirs-update
	end

	set -x XDG_CONFIG_HOME "$HOME/.config"
	set -x XDG_CACHE_HOME "$HOME/.cache"
	set -x XDG_DATA_HOME "$HOME/.local/share"
	set -x XDG_STATE_HOME "$HOME/.local/state"

	set --path -x XDG_DATA_DIRS $XDG_DATA_DIRS
	set --path -x XDG_CONFIG_DIRS $XDG_CONFIG_DIRS
	#set -x XDG_DATA_DIRS "/usr/share/kde-settings/kde-profile/default/share:/usr/local/share:/usr/share"
	#set -x XDG_CONFIG_DIRS "$HOME/.config/kdedefaults:/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg"
end
