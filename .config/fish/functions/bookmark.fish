function bookmark --argument-names cmd value name --description "A installer of linux utilities"
    switch "$cmd"
        case -h --help help
            echo "Usage: bookmark add <value> <name>     Add bookmark to the list, name is optional"
            echo "       bookmark help                   Print help"
        case add
            echo "$name: $value"
        case '*'
            echo "Use \"bookmark help\" to print help"
    end
end
