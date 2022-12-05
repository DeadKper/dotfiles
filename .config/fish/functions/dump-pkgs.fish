function dump-pkgs --argument folder
  if test -z "$folder"
    set folder "$HOME/Downloads"
  end

  if type -q dnf
    dnf repoquery --userinstalled --qf "%{name}" > $folder/dnf-packages.txt
  end

  if type -q flatpak
    flatpak list --app --columns=application | sed "s/Application ID//g" > $folder/flatpak-packages.txt
  end

  if type -q nix-env
    nixe list | sed -r "s/(.*)-[0-9\.]+/\1/g" > $folder/nix-packages.txt
  end
end