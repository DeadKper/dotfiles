add_export DOOMDIR $HOME/.config/doom
fish_add_path $HOME/.config/emacs/bin

function emacs --wraps="emacsclient -c -a \"emacs\"" --description "alias emacs=emacsclient -c -a \"emacs\""
  switch "$argv[1]"
  case --daemon
    command emacs $argv
  case --sync sync
    pkill emacs
    sleep 1
    doom sync
    command emacs --daemon
  case -sv --server
    set --erase argv[1]
    command emacs $argv
  case "*"
    emacsclient -c -a "emacs" $argv
  end
end
