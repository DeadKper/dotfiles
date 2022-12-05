function save --argument string path reference
  set --local perm (sudo echo "y" || echo "n")

  if test $perm = n
    return 1
  end

  if test -z "$reference"
    set reference $path
  end

  if not test -e "$reference"
    echo "$reference is not a file, a reference file is needed to copy permissions"
    return 1
  end

  set --local file "$HOME/.temp_save_file"

  echo $string > $file
  sudo chown --reference=$reference $file
  sudo mv $file $path
end