if status is-login; or not set -q HOME_INIT
    set -x HOME_INIT
    set -x --path PATH $PATH
    add-path PATH ~/.local/scripts ~/.local/bin

    # Add default paths just in case
    set -x --path PATH $PATH
    add-path -a PATH /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
end
