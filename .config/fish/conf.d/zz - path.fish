set -x --path PATH $PATH

if test -d ~/.local/bin
    add-path PATH ~/.local/bin
end

if test -d ~/.local/scripts
    add-path PATH ~/.local/scripts
end

add-path -a PATH /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
