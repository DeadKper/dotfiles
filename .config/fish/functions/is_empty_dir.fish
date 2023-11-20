function is_empty_dir
    test -d "$argv"
    or return 1 # not a directory, so not an empty directory
    # count counts how many arguments it received
    # if this glob doesn't match, it won't get arguments
    # and so it will return 1
    # because we *want* an empty directory, turn that around.
    # the `{.*,*}` ensures it matches hidden files as well.
    not count $argv/{.*,*} >/dev/null
end
