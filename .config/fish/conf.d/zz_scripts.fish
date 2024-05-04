if status is-login; or not set -q HOME_INIT
    set -x HOME_INIT
    set -x --path PATH $PATH
    add-path PATH ~/.local/scripts ~/.local/bin
end
