function steamargs
    set -l args gamemoderun gamescope
    set -l def_res (string split 'x' $(xdpyinfo | awk '/dimensions/ {print $2}'))
    set -l skip_count 0

    if test (count $argv) -eq 0
        set argv --defaults --mouse
    end

    for i in (seq 1 1 (count $argv))
        if test $skip_count -gt 0
            set skip_count (math $skip_count - 1)
            continue
        end

        switch $argv[$i]
            case --fsr
                set args $args -F fsr --sharpness
                if test ! (echo $argv[(math $i + 1)] | grep -E '^[0-9]+$')
                    set args $args 10
                end
            case --cursor or --mouse
                set args $args --force-grab-cursor
            case --keyboard
                set args $args -g
            case --game-res
                if test (echo $argv[(math $i + 1)] | grep -E '^[0-9]+x[0-9]+$')
                    set tmp_res (string split 'x' $argv[(math $i + 1)])
                    set args $args -h $tmp_res[2] -w $tmp_res[1]
                    set skip_count 1
                else
                    set args $args -h $def_res[2] -w $def_res[1]
                end
            case --output-res
                if test (echo $argv[(math $i + 1)] | grep -E '^[0-9]+x[0-9]+$')
                    set tmp_res (string split 'x' $argv[(math $i + 1)])
                    set args $args -H $tmp_res[2] -W $tmp_res[1]
                    set skip_count 1
                else
                    set args $args -H $def_res[2] -W $def_res[1]
                end
            case --unfocused
                set args $args -o
            case --defaults
                set args $args -h $def_res[2] -w $def_res[1] -H $def_res[2] -W $def_res[1] -b -o 5
            case --fsr-defaults
                set args $args -h 1280 -w 720 -H $def_res[2] -W $def_res[1] -F fsr --sharpness 10 $def_res[1] -b -o 5
            case --shader
                set args __GL_SHADER_CACHE=1 __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1 DXVK_HUD=compiler __GL_DXVK_OPTIMIZATIONS=1 STAGING_SHARED_MEMORY=1 $args
            case '*'
                set args $args $argv[$i]
        end
    end

    echo $args "%command%"
end
