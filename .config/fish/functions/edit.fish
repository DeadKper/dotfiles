function edit --wraps='sudo sudoedit' --description 'alias edit=\'sudo EDITOR="$(which nvim)" sudoedit\''
    sudo EDITOR="$(which nvim)" sudoedit $argv
end
