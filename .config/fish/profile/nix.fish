# If .nix-profile folder exists this has not already been set
if test -e /home/missael/.nix-profile; and test -z "$__ETC_PROFILE_NIX_SOURCED"
    # Only execute this file once per shell.
    set __ETC_PROFILE_NIX_SOURCED 1

    # Set up environment.
    # This part should be kept in sync with nixpkgs:nixos/modules/programs/environment.nix
    set --export NIX_PROFILES "/nix/var/nix/profiles/default" "$HOME/.nix-profile"

    # Set $NIX_SSL_CERT_FILE so that Nixpkgs applications like curl work.
    if test -n "$NIX_SSH_CERT_FILE"
        : # Allow users to override the NIX_SSL_CERT_FILE
    else if test -e /etc/ssl/certs/ca-certificates.crt # NixOS, Ubuntu, Debian, Gentoo, Arch
        set --export NIX_SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
    else if test -e /etc/ssl/ca-bundle.pem # openSUSE Tumbleweed
        set --export NIX_SSL_CERT_FILE /etc/ssl/ca-bundle.pem
    else if test -e /etc/ssl/certs/ca-bundle.crt # Old NixOS
        set --export NIX_SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
    else if test -e /etc/pki/tls/certs/ca-bundle.crt # Fedora, CentOS
        set --export NIX_SSL_CERT_FILE /etc/pki/tls/certs/ca-bundle.crt
    else if test -e "$HOME/.nix-profile/etc/ssl/certs/ca-bundle.crt" # fall back to cacert in Nix profile
        set --export NIX_SSL_CERT_FILE "$HOME/.nix-profile/etc/ssl/certs/ca-bundle.crt"
    else if test -e "$HOME/.nix-profile/etc/ca-bundle.crt" # old cacert in Nix profile
        set --export NIX_SSL_CERT_FILE "$HOME/.nix-profile/etc/ca-bundle.crt"
    else
        # Fall back to what is in the nix profiles, favouring whatever is defined last.
        for i in $NIX_PROFILES
            if test -e "$i/etc/ssl/certs/ca-bundle.crt"
                set --export NIX_SSL_CERT_FILE "$i/etc/ssl/certs/ca-bundle.crt"
            end
        end
    end

    # Allow unfree
    set --export NIXPKGS_ALLOW_UNFREE 1

    fish_add_path "/nix/var/nix/profiles/default/bin"
    fish_add_path "$HOME/.nix-profile/bin"

    set -x XDG_DATA_HOME $XDG_DATA_HOME
    if not test -e "$XDG_DATA_HOME/nix-env/share/"
        mkdir -p "$XDG_DATA_HOME/nix-env/share" 2>/dev/null
    end

    # Set manpath
    set -x --path MANPATH $MANPATH
    add_to_path MANPATH "$XDG_DATA_HOME/nix-env/share/man"

    # Populate bash completions, .desktop files, etc
    set -x --path XDG_DATA_DIRS $XDG_DATA_DIRS
    add_to_path XDG_DATA_DIRS "$XDG_DATA_HOME/nix-env/share" "/nix/var/nix/profiles/default/share"

    function nix-env --wraps nix-env
        if not test "$argv" = "--sync"
            command nix-env $argv
        end
        # Sync symlinks to another folder to stop nix slowing down the pc on startup
        rsync -pqrLK --chmod=u+rwx --delete-after "$HOME/.nix-profile/share/" "$XDG_DATA_HOME/nix-env/share/" &>/dev/null
        update-desktop-database "$XDG_DATA_HOME/nix-env/share/applications" &>/dev/null
    end

    nix-env --sync
end
