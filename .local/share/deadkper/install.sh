#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
	echo 'script cannot run as root'
	exit
fi

trap "pkill -P $$; exit 1" kill term int hup
trap "pkill -P $$; exit 0" exit

echo Sudo permission needed, press ctrl+c to stop script

while ! sudo echo -n; do
	:
done

while [ true ]; do sudo -nv &> /dev/null; sleep 30; done &

echo Detecting install target...
distro="$(grep '^NAME=' /etc/os-release | cut -d = -f 2 | sed -E 's/^"|"$//g')"
like="$(grep '^ID_LIKE=' /etc/os-release | cut -d = -f 2 | sed -E 's/^"|"$//g')"
box="$(test -f /run/.containerenv && echo y || test -f /.dockerenv && echo y)"
wsl="$(type wslpath >/dev/null 2>&1 && echo y)"

unset suffix
if test "$wsl" = y; then
	suffix=.wsl
elif test "$box" = y; then
	suffix=.box
fi

setup_file="$HOME/.local/state/.setup_done"

if ! test -f "$setup_file"; then
	echo Setup file not found, installing from scratch

	echo Setting up folder structure...
	mkdir -p "$HOME/.local/scripts"
	mkdir -p "$HOME/.local/share"
	mkdir -p "$HOME/.local/bin"
	mkdir -p "$HOME/.config"

	echo Setting up enviroment...
	export RUSTUP_HOME="$HOME/.local/share/rust/rustup"
	export CARGO_HOME="$HOME/.local/share/rust/cargo"
	export PATH="$HOME/.local/scripts:$HOME/.local/bin:$CARGO_HOME/bin:$PATH"

	echo Installing yadm...
	yadm_dir="$HOME/.local/share/yadm-project"
	if ! test -d "$yadm_dir"; then
		git clone https://github.com/TheLocehiliosan/yadm.git "$yadm_dir" &> /dev/null
		git checkout "$(git -C /tmp/yadm ls-remote -qt --sort=committerdate | tail -n 1 | sed -En 's,.*refs/tags/(.*).*,\1,p')" &> /dev/null
		ln -sr "$yadm_dir/yadm" ~/.local/bin/
	fi

	echo Setting up dotfiles...
	if ! test -d "$HOME/.local/share/yadm"; then
		if test "$1" = work; then
			yadm clone -b work 'https://github.com/DeadKper/dotfiles'
		else
			yadm clone -b main 'https://github.com/DeadKper/dotfiles'
		fi
	fi
	yadm submodule update --init --recursive

	unset add
	unset remove
	unset sync
	unset upgrade
	unset rebos_manager
	many_args="true"

	echo Updating and installing needed dependencies...
	if test "$distro" = 'openSUSE Tumbleweed'; then
		hostname="tumbleweed${suffix}"
		sudo zypper update --best-effort --recommends --allow-downgrade -yl
		sudo zypper install -yl --recommends -t pattern devel_basis devel_C_C++
		sudo zypper install -yl --recommends libopenssl-devel git fish rustup
		flatpak='sudo zypper install -yl --recommends flatpak'
		add="sudo zypper install -yl --recommends #:?"
		remove="sudo zypper remove -yu #:?"
		sync="sudo zypper update --best-effort --recommends --allow-downgrade -yl"
		upgrade="sudo zypper dist-upgrade --recommends --allow-downgrade -yl"
		rebos_manager=y

		if test "$wsl" != y -a "$box" != y; then
			sudo zypper install opi
			opi codecs
			sudo zypper install qt6-multimedia gstreamer-plugins-libav
		fi
	elif test "$distro" = 'Fedora Linux'; then
		hostname="fedora${suffix}"
		sudo dnf update -y
		sudo dnf groupinstall -y "Development Tools" "Development Libraries"
		sudo dnf install -y git fish rustup
		flatpak='sudo dnf install -y flatpak'
		add="sudo dnf install -y #:?"
		remove="sudo dnf remove -y #:?"
		upgrade="sudo dnf update -y"
		rebos_manager=y
	fi

	if test "$wsl" != y; then
		echo Setting up flatpak...
		eval $flatpak

		flatpak remote-delete flathub -y
		flatpak remote-delete flathub-beta -y
		flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

		flatpak override --user --filesystem=/usr/share/icons:ro
		flatpak override --user --filesystem=xdg-data/icons:ro
		flatpak override --user com.usebottles.bottles --filesystem=xdg-data/applications
		flatpak override --user com.usebottles.bottles --filesystem=xdg-data/share/Steam
		flatpak override --user com.usebottles.bottles --filesystem=~/.var/app/com.valvesoftware.Steam/data/Steam
		flatpak override --user io.github.spacingbat3.webcord --filesystem=home:ro
	fi

	echo Setting up fish...
	fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
	fish -c "echo n | fisher install ilancosman/tide@v6"
	fish -c "tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='One line' --prompt_spacing=Compact --icons='Few icons' --transient=No"
	
	echo Setting up rust...
	rustup default stable

	echo Installing rebos...
	cargo install rebos

	echo Setting up rebos...
	rebos setup
	rebos config init

	if test -n "$hostname" -a "$hostname" != "$(hostname)"; then
		rm "$HOME/.config/rebos/machines/$(hostname)/gen.toml"
		ln -sr "$HOME/.config/rebos/machines/$hostname/gen.toml" "$HOME/.config/rebos/machines/$(hostname)/gen.toml"
	fi

	if test -z "$rebos_manager"; then
		add=""
		remove=""
		sync=""
		upgrade=""
		echo 'rebos needs manual config for current package manager (~/.config/rebos/managers/system.toml)'
	fi

	{
		echo '# --------------------------- #'
		echo '#    Manager Configuration    #'
		echo '# --------------------------- #'
		echo ''
		echo '# Make sure to enter the exact command you use as the normal user!'
		echo "# That means including 'sudo' or 'doas' or whatever if the command needs it."
		echo "# Where you would put items, enter '#:?'."
		echo ''
		echo '# Example: add = "sudo apt install #:?"'
		echo ''
		echo "$(test -n "${add+x}" && echo '' || echo '# ')add = \"$add\" # Example: sudo apt install #:?"
		echo "$(test -n "${remove+x}" && echo '' || echo '# ')remove = \"$remove\" # Example: sudo apt remove #:?"
		echo "$(test -n "${sync+x}" && echo '' || echo '# ')sync = \"$sync\" # Example: sudo apt update"
		echo "$(test -n "${upgrade+x}" && echo '' || echo '# ')upgrade = \"$upgrade\" # Example: sudo apt upgrade"
		echo ''
		echo 'plural_name = "system packages"'
		echo ''
		echo 'hook_name = "system_packages" # This is used in hooks. (Example: post_system_packages_add)'
		echo ''
		echo '# ------------------------------- #'
		echo '#    Additional configuration.    #'
		echo '# ------------------------------- #'
		echo ''
		echo "# many_args = BOOL: Can you supply many items as an argument? Example: 'sudo apt install git vim wget'"
		echo ''
		echo '[config]'
		echo "many_args = $many_args"
	} > "$HOME/.config/rebos/managers/system.toml"

	if test -n "$rebos_manager"; then
		rebos gen commit 'initial install'
		rebos gen current build
	fi

	echo Base instalation finished, creating setup file
	mkdir -p "$(dirname "$setup_file")"
	touch "$setup_file"
fi

if test "$wsl" != y -a "$box" != y; then
	echo Setting borderless maximized windows...
	kde=(
		'6'
		'5'
		''
	)
	for ver in "${kde[@]}"; do
		if type "kwriteconfig${ver}" >/dev/null 2>&1; then
			eval "kwriteconfig${ver}" --file ~/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
			break
		fi
	done
	for ver in "${kde[@]}"; do
		if type "qdbus${ver}" >/dev/null 2>&1; then
			eval "qdbus${ver}" org.kde.KWin /KWin reconfigure
			break
		fi
	done
fi

if test "$wsl" = y; then
	echo "Setting up windows..."
	wuser=$(powershell.exe "\$env:UserName" | sed -E 's,(\S+).*,\1,g')
	mkdir -p "/mnt/c/Users/$wuser/.config"
	cp -rf ~/.config/wezterm/ "/mnt/c/Users/$wuser/.config"
fi

group_add=(
	'docker'
	'libvirt'
	'wheel'
	'sudo'
)

for group in "${group_add[@]}"; do
	if getent group "$group" >/dev/null; then
		sudo usermod -a -G "$group" "$USER"
	fi
done
