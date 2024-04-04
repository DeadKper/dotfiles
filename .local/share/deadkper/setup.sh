#!/bin/sh

if [ "$EUID" -eq 0 ]; then
	echo 'needs to be run as the user'
	return 1
fi

if [ -z $@ ]; then
	curl -sL https://raw.githubusercontent.com/DeadKper/dotfiles/main/.local/share/deadkper/setup.sh > /tmp/setup.sh
	chmod +x /tmp/setup.sh
	/tmp/setup.sh y
	exit
fi

if type yadm &> /dev/null; then
	echo yadm instalation detected, stopping install
	echo if you need help with something, just use \'cat /tmp/setup.sh\'
	exit
fi

echo sudo permission needed, press ctrl+c to cancel

while [ true ]; do
	sleep 5
	sudo printf "" && break
done

sh -c 'while [ true ]; do sudo -nv &> /dev/null && sleep 5 || exit; done' &

wsl=$(type wsl.exe &> /dev/null && echo y || echo n)

if [ $wsl = y ]; then
	echo wsl container detected!
	echo cmd.exe /c "fedora config --default-user '$USER'" 2> /dev/null
fi

echo installing development utils
sudo dnf copr enable -y atim/starship &> /dev/null
sudo dnf update -y
sudo dnf install -y git fish parallel tmux neovim gcc zlib-ng cmake zoxide ripgrep sd fd-find fzf starship
sudo dnf groupinstall -y "Development Tools" "Development Libraries"
sudo chsh -s $(which fish) "$USER"

# setting up folders
mkdir -p "$HOME/.local/scripts"
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config"

echo cloning yadm...
yadm=/tmp/yadm/yadm
git clone https://github.com/TheLocehiliosan/yadm.git /tmp/yadm &> /dev/null
git checkout $(git -C /tmp/yadm ls-remote -qt --sort=committerdate | tail -n 1 | sed -En 's,.*refs/tags/(.*).*,\1,p') &> /dev/null

if [ $wsl = y ]; then
	echo cloning work dotfiles...
	$yadm clone -b work 'https://github.com/DeadKper/dotfiles'
	$yadm submodule update --init --recursive
else
	echo cloning dotfiles...
	$yadm clone 'git@github.com:DeadKper/dotfiles.git'
	$yadm submodule update --init --recursive

	git -C "$HOME/.config/nvim" remote set-url origin git@github.com:DeadKper/nvim.git &> /dev/null
	git -C "$HOME/.config/nvim" checkout main &> /dev/null
	git -C "$HOME/.config/nvim" pull &> /dev/null

	echo installing user applications
	sudo dnf install -y flatpak btop python3 pipx steam gamemode gamescope alacritty

	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install -yu com.bitwarden.desktop
	flatpak install -yu com.github.tchx84.Flatseal
	flatpak install -yu com.nextcloud.desktopclient.nextcloud
	flatpak install -yu com.usebottles.bottles
	flatpak install -yu io.freetubeapp.FreeTube
	flatpak install -yu io.github.spacingbat3.webcord
	flatpak install -yu it.mijorus.gearlever
	flatpak install -yu net.agalwood.Motrix
	flatpak install -yu org.gimp.GIMP
	flatpak install -yu org.gtk.Gtk3theme.Breeze
	flatpak install -yu org.inkscape.Inkscape
	flatpak install -yu org.kde.kdenlive
	flatpak install -yu org.kde.krita
	flatpak install -yu io.gitlab.librewolf-community

	echo installing protonup
	pipx install protonup

	echo installing proton ge
	fish -c proton-update

	kwriteconfig6 --file ~/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
	qdbus org.kde.KWin /KWin reconfigure
fi

sudo -k
fish
