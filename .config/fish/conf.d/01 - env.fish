if test -z "$ENV_SET"
	# Add to path
	fish_add_path "$HOME/.local/bin"
	fish_add_path "$HOME/.surrealdb"

	# Configure variables
	set fish_greeting
	set -xg EDITOR nvim
	set -xg VISUAL nvim
	set -xg NIXPKGS_ALLOW_UNFREE 1
	set -xg XKB_DEFAULT_LAYOUT (setxkbmap -query | grep layout | sed -r "s/^layout:\t* *(.*)/\1/g")
	set -xg XKB_DEFAULT_VARIANT (setxkbmap -query | grep variant | sed -r "s/^variant:\t* *(.*)/\1/g")
end

# Set XDG variables if not set
if test -z "$XDG_CONFIG_HOME"
	set -l XDG_FILE "$HOME/.config/user-dirs.dirs"

	if not test -f "$XDG_FILE"
		xdg-user-dirs-update

		echo '
		XDG_CONFIG_HOME="$HOME/.config"
		XDG_CACHE_HOME="$HOME/.cache"
		XDG_DATA_HOME="$HOME/.local/share"
		XDG_STATE_HOME="$HOME/.local/state"

		XDG_DATA_DIRS="/usr/share/kde-settings/kde-profile/default/share:/usr/local/share:/usr/share"
		XDG_CONFIG_DIRS="$HOME/.config/kdedefaults:/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg"' | sed -r "s/^ *//g" >> $XDG_FILE
	end

	set -l xdg_list (cat "$XDG_FILE" | sed -rn "s/(^XDG.+)/\1/p" | sed 's,$HOME,'"$HOME"',g')

	for var in $xdg_list
		set -l dict (echo $var | sed "s/\"//g" | string split "=")
		set -x $dict[1] "$dict[2]"
	end
end

# Parse XDG path vars
parse_path XDG_DATA_DIRS
parse_path XDG_CONFIG_DIRS
fish_add_path "$HOME/.config/emacs/bin"
