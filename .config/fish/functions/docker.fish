if command -q podman; and not command -q docker
    function docker --description 'alias docker=podman'
        command podman $argv
    end
end
