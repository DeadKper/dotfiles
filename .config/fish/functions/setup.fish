function setup --argument-names cmd app --description "A installer of linux utilities"
  switch "$cmd"
  case -h --help help
    echo "Usage: setup list                   List available setups to install"
    echo "       setup install <application>  Install application"
    echo "       setup help                   Print help"
  case list
    echo "Applications:"
    echo "  brew"
    echo "  gimp"
    echo "  noisetorch"
    echo "  wallpaper-engine"
    echo "  doom-emacs"
    echo "  nix"
  case install
    switch "$app"
    case gimp
      flatpak install flathub org.gimp.GIMP -y

      set -l ORG Diolinux
      set -l REPO PhotoGIMP
      set -l FILE flatpak\.zip

      set -l url (curl -s https://api.github.com/repos/$ORG/$REPO/releases/latest \
        | sed -n -r "s/.*browser_download_url.*\"(.*$FILE)\".*/\1/ip")

      set -l filename (echo $url | sed -n -r "s/.*releases\/download\/.*\/(.*)/\1/ip")

      wget --output-document=$HOME/Downloads/$filename --continue $url

      cd $HOME/Downloads

      set -l dir (echo $filename | sed 's/\.[^.]*$//')

      if test -d $dir
        rm -rf $dir
      end

      unzip $filename

      cd $dir

      rsync -ah --info=progress2 -r .local/ $HOME/.local
      rsync -ah --info=progress2 -r .var/ $HOME/.var

      cd ..
      rm -rf $dir
      rm -f $filename
    case wallpaper-engine
      set --local folder "$HOME/.local/share/wallpaper-engine-kde-plugin"

      if not test -d $folder
        sudo dnf install --skip-broken vulkan-headers plasma-workspace-devel \
          kf5-plasma-devel gstreamer1-libav lz4-devel mpv-libs-devel python3-websockets \
          qt5-qtbase-private-devel qt5-qtx11extras-devel qt5-qtwebchannel-devel \
          qt5-qtwebsockets-devel cmake -y
        cd "$HOME/.local/share"
        # Download source
        git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git
        cd wallpaper-engine-kde-plugin
      else
        cd "$folder"
        git pull origin main
      end

      # Download submodule (glslang)
      git submodule update --init

      rm -rf build

      # Configure
      # 'USE_PLASMAPKG=ON': using plasmapkg2 tool to install plugin
      mkdir build && cd build
      cmake .. -DUSE_PLASMAPKG=OFF

      # Build
      make

      # Install package (ignore if USE_PLASMAPKG=OFF for system-wide installation)
      make install_pkg
      # install lib
      sudo make install

      killall plasmashell
      kwin --replace
      kstart plasmashell
    case brew
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      echo 'if not type -q brew
          set -l brew_paths /home/linuxbrew/.linuxbrew/bin /opt/homebrew/bin /usr/local/bin /usr/bin /bin /home/linuxbrew/.linuxbrew/sbin /opt/homebrew/sbin /usr/local/sbin /usr/sbin /sbin

          for brew_path in $brew_paths
            if test -f $brew_path/brew
              eval ($brew_path/brew shellenv)
              break
            end
          end
        end' | sed -r "s/^ {8}//g" >$HOME/.config/fish/conf.d/brew.fish
      source $HOME/.config/fish/conf.d/brew.fish
    case noisetorch
      set -l ORG noisetorch
      set -l REPO NoiseTorch
      set -l FILE \.tgz

      set -l url (curl -s https://api.github.com/repos/$ORG/$REPO/releases/latest \
        | sed -n -r "s/.*browser_download_url.*\"(.*$FILE)\".*/\1/ip")

      set -l filename (echo $url | sed -n -r "s/.*releases\/download\/.*\/(.*)/\1/ip")

      wget --output-document=$HOME/Downloads/$filename --continue $url

      cd $HOME/Downloads

      tar -zxvf $filename

      rsync -ah --info=progress2 -r .local/ $HOME/.local

      rm -rf .local
      rm -f $filename
      cd
    case doom-emacs
      set --local folder "$HOME/.config/emacs"
      if not test -d $folder
        echo 'set -x DOOMDIR $HOME/.config/doom
          fish_add_path $HOME/.config/emacs/bin

          function emacs --wraps="emacsclient -c -a \"emacs\"" --description "alias emacs=emacsclient -c -a \"emacs\""
            switch "$argv[1]"
            case --daemon
            command emacs $argv
            case --sync
            doom sync
            pkill emacs --daemon
            command emacs --daemon
            case -sv --server
            set --erase argv[1]
            command emacs $argv
            case "*"
            emacsclient -c -a "emacs" $argv
            end
          end' | sed -r "s/^ {14}//g" >$HOME/.config/fish/conf.d/emacs.fish
        source $HOME/.config/fish/conf.d/emacs.fish

        sudo dnf install --skip-broken emacs git ripgrep fd-find -y

        git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
        ~/.config/emacs/bin/doom install
        mkdir "$HOME/.config/doom"
        mkdir "$HOME/.config/doom/snippets/"
      else
        cd "$folder"
        git pull --depth 1 https://github.com/doomemacs/doomemacs
        cd
        ~/.config/emacs/bin/doom install
      end
    case nix
      sh (curl -L https://nixos.org/nix/install | psub) --daemon
      mkdir "$XDG_DATA_HOME/nix-env/" 2>/dev/null
      mkdir "$HOME/.config/nixpkgs/" 2>/dev/null
      # echo '{
      #     packageOverrides = pkgs: {
      #       nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      #         inherit pkgs;
      #       };
      #     };
      #   }' | sed -r "s/^ {8}//g" > "$HOME/.config/nixpkgs/config.nix"
      source "$HOME/.config/fish/conf.d/nix.fish"
      source "$HOME/.config/fish/conf.d/nix-conf.fish"
      nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
      nix-channel --update
    case '*'
        echo "Use \"setup list\" to list available apps"
    end
  case remove
    switch "$app"
    case nix
      sudo rm -rf /etc/profile/nix.sh /etc/nix /nix ~root/.nix-profile ~root/.nix-defexpr ~root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels "$XDG_DATA_HOME/nix-env" "$HOME/.config/nixpkgs/"

      for file in (find /etc -name "*.backup-before-nix" 2>/dev/null)
        sudo mv "$file" "$(echo $file | sed "s/.backup-before-nix//g")"
      end

      # If you are on Linux with systemd, you will need to run:
      sudo systemctl stop nix-daemon.socket
      sudo systemctl stop nix-daemon.service
      sudo systemctl disable nix-daemon.socket
      sudo systemctl disable nix-daemon.service
      sudo systemctl daemon-reload
    case '*'
    end
  case '*'
    echo "Use \"setup help\" to print help"
  end
end
