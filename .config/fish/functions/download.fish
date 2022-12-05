function download --wraps='wget -c --content-disposition -O "$HOME/Downloads"' --wraps='cd "$HOME/Downloads" && wget -c --content-disposition' --description 'alias download=cd "$HOME/Downloads" && wget -c --content-disposition'
  cd "$HOME/Downloads" && wget -c --content-disposition $argv; 
end
