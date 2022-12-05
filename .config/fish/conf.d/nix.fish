if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
  set -xg NIXPKGS_ALLOW_UNFREE 1
  add_path PATH "$HOME/.nix-profile/bin"
  add_path XDG_DATA_DIRS "$XDG_DATA_HOME/nix-env/share"

  function nixe
    set -l comm (echo "$argv[1]")
    set -e argv[1]
    set -le update_desk_db
    switch $comm
    case -xu
      set update_desk_db 1
    case -xgc
      nix-collect-garbage --delete-older-than 30d
    case -gc
      nix-collect-garbage $argv
    case -xn
      nix-env -f "<nixpkgs>" $argv
    case -xun -xnu
      nix-env -f "<nixpkgs>" $argv
      set update_desk_db 1
    case install
      nix-env -f "<nixpkgs>" -iA $argv
      set update_desk_db 1
    case update
      nix-env -f "<nixpkgs>" -uA $argv
      set update_desk_db 1
    case remove
      nix-env -f "<nixpkgs>" -e $argv
      set update_desk_db 1
    case list
      nix-env -f "<nixpkgs>" -q $argv
    case search
      nix-env -f "<nixpkgs>" -qa $argv
    case "*"
      nix-env $comm $argv
    end
    if test -n "$update_desk_db"
      rsync -pqrLK --chmod=u+rwx "$HOME/.nix-profile/share/" "$XDG_DATA_HOME/nix-env/share/" --delete-after 2>/dev/null
      update-desktop-database "$XDG_DATA_HOME/nix-env/share/applications"
    end
  end
end
