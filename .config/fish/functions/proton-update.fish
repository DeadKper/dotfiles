function proton-update
    if test -n "$XDG_DATA_HOME"
        set -f steam "$XDG_DATA_HOME/Steam/compatibilitytools.d"
    else
        set -f steam "$HOME/.local/share/Steam/compatibilitytools.d"
    end

    if not type -q protonup
        echo protonup not installed 1>&2
        return 1
    end

    set -l newest (protonup --releases | tail -n 1)

    if not test -f "$steam/GE-Latest/compatibilitytool.vdf"
        protonup -d "$steam"
        mkdir -p "$steam/GE-Latest"
        set -l print '"compatibilitytools"'
        set -a print '{'
        set -a print '  "compat_tools"'
        set -a print '  {'
        set -a print '    "GE-Latest" // Internal name of this tool'
        set -a print '    {'
        set -a print '      // - This manifest can be placed directly in compatibilitytools.d, in which case this should'
        set -a print '      //   be the relative or absolute path to the tool\'s dist directory.'
        set -a print '      "install_path" "../'$newest'"'
        set -a print ''
        set -a print '      // For this template, we\'re going to substitute the display_name key in here, e.g.:'
        set -a print '      "display_name" "GE-Latest"'
        set -a print ''
        set -a print '      "from_oslist"  "windows"'
        set -a print '      "to_oslist"    "linux"'
        set -a print '    }'
        set -a print '  }'
        set -a print '}'
        printf '%s\n' $print >"$steam/GE-Latest/compatibilitytool.vdf"
    end

    if not protonup -l | rg -F "$newest" &>/dev/null
        protonup -t "$newest" -y

        cat "$steam/GE-Latest/compatibilitytool.vdf" | sd '("install_path") .*' '$1 "../'$newest'"' >"$steam/GE-Latest/compatibilitytool.vdf"
    end
end
