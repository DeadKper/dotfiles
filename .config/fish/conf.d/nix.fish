if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
  set -x NIXPKGS_ALLOW_UNFREE 1

  fish_add_path "$HOME/.nix-profile/bin"

  set -x --path XDG_DATA_DIRS $XDG_DATA_DIRS
  set -q XDG_DATA_DIRS[1]; or set XDG_DATA_DIRS /usr/local/share /usr/share
  add_path XDG_DATA_DIRS "$XDG_DATA_HOME/nix-env/share" $XDG_DATA_DIRS

  function nix-env
    command nix-env $argv
    rsync -pqrLK --chmod=u+rwx "$HOME/.nix-profile/share/" "$XDG_DATA_HOME/nix-env/share/" --delete-after &>/dev/null
    update-desktop-database "$XDG_DATA_HOME/nix-env/share/applications" &>/dev/null
  end
end
