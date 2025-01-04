#!/usr/bin/env bash

main() {
	NAME="$1"
	SERV="$NAME.service"
	CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
	SYSD="$CONF/systemd/user"

	if test "$(type "$SERV" 2>/dev/null | head -1)" = "$SERV is a function"; then
		if ! test -d "$SYSD"; then
			mkdir -p "$SYSD"
		fi

		if test -f "$SYSD/$SERV"; then
			systemctl --user start $NAME && systemctl --user enable $NAME
			exit 0
		else
			$SERV
		fi
	else
		error "[ERROR]: service named '$NAME' not found in script"
	fi

	systemctl --user stop $NAME >/dev/null 2>&1
	systemctl --user daemon-reload
	if systemctl --user start $NAME; then
		systemctl --user disable $NAME >/dev/null 2>&1
		systemctl --user enable $NAME
	fi
}

error() {
	printf '%s\n' "$@" >&2
	exit 1
}

sudoers() {
	if sudo -n echo -n >/dev/null 2>&1; then
		sudo echo -n || error "[ERROR]: sudo priviliges needed to install sudoers permission for '$NAME'"
	fi

	sudoers="/etc/sudoers.d"
	tmp="$(mktemp)"
	if sudo test -f "$sudoers/$NAME"; then
		grep -v "^$USER " "$sudoers/$NAME" > "$tmp"
	fi
	echo "$USER ALL=(root:root) NOPASSWD:" "$@" >> "$tmp"
	sudo install -m 400 -o root -g root "$tmp" "$sudoers/$NAME"
	rm -f "$tmp"
}

kanata.service() {
	sudoers "$(which kanata) -c *"

	cat <<EOF > "$SYSD/$SERV"
[Unit]
Description=kanata daemon service
Documentation=https://github.com/jtroo/kanata

[Service]
Type=forking
ExecStart=$(which sudo) -b $(which kanata) -c "$CONF/kanata/kanata.kbd"
KillMode=control-group

RestartSec=2

[Install]
WantedBy=default.target
EOF
}

ydotoold.service() {
	sudoers "$(which ydotoold) -p * -o *"

	cat <<EOF > "$SYSD/$SERV"
[Unit]
Description=ydotool daemon service
Documentation=man:ydotoold(8)

[Service]
Type=forking
ExecStart=$(which sudo) -b $(which ydotoold) -p "$HOME/.local/state/ydotool.socket" -o $(id -u):$(id -g)
KillMode=control-group

RestartSec=2

[Install]
WantedBy=default.target
EOF
}

kdeconnectd.service() {
	cat <<EOF > "$SYSD/$SERV"
[Unit]
Description=kdeconnect daemon
Documentation=

[Service]
Type=simple
ExecStart=$(which kdeconnectd) --replace
KillMode=control-group

RestartSec=2

[Install]
WantedBy=default.target
EOF
}

easyeffects.service() {
	cat <<EOF > "$SYSD/$SERV"
[Unit]
Description=easyeffects daemon service
Documentation=

[Service]
Type=simple
ExecStartPre=/bin/sleep 10
ExecStart=$(which flatpak) run com.github.wwmm.easyeffects --gapplication-service
ExecStop=/usr/bin/pkill easyeffects
KillMode=control-group

RestartSec=2

[Install]
WantedBy=default.target
EOF
}

main "$@"
