if status is-interactive
    abbr mkdir 'mkdir -p'

    if type -q ansible
        abbr apl ansible-playbook
        abbr apv ansible-playbook --extra-vars
        abbr apa ansible-playbook asd.yaml -i

        abbr agl ansible-galaxy
        abbr agi ansible-galaxy init

        abbr aed ansible-edit

        abbr arn ansible-run -m
        abbr arc ansible-run -m shell -a
        abbr arx ansible-run -m script -a

        abbr alg ansible-logs

        abbr atp ansible-template
    end
end
