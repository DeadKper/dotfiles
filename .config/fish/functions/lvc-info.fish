function lvc-info --wraps='dmsetup status' --description 'alias lvc-info=dmsetup status'
    if not count $argv &>/dev/null
        echo 'usage: lvc-info [lvm]'
        return 1
    end

    set -l info
    if type -q distrobox-host-exec
        set info (distrobox-host-exec sudo dmsetup status $argv | string split ' ')
    else
        set info (sudo dmsetup status $argv | string split ' ')
    end

    if test -z "$info"
        return 1
    end

    set -l MetadataBlockSize $info[4]
    set -l NrMetadataBlocks (echo $info[5] | string split '/')

    set -l CacheBlockSize $info[6]
    set -l NrCacheBlocks (echo $info[7] | string split '/')

    set -l NrReadHits $info[8]
    set -l NrReadMisses $info[9]
    set -l NrWriteHits $info[10]
    set -l NrWriteMisses $info[11]

    set -l NrDemotions $info[12]
    set -l NrPromotions $info[13]
    set -l NrDirty $info[14]

    echo " --- LVM Cache report of $argv ---"

    set -l MetaUsage (math "$NrMetadataBlocks[1] * 100 / $NrMetadataBlocks[2]")
    set -l CacheUsage (math "($NrCacheBlocks[1] * 100) / $NrCacheBlocks[2]")
    # printf " Cache Usage: %0.1f%%\n" $CacheUsage
    # printf " Metadata Usage: %0.1f%%\n" $MetaUsage

    set -l ReadRate (math "($NrReadHits * 100) / ($NrReadMisses + $NrReadHits)")
    set -l WriteRate (math "($NrWriteHits * 100) / ($NrWriteMisses + $NrWriteHits)")
    # printf " Read Hit Rate: %0.1f%%\n" $ReadRate
    # printf " Write Hit Rate: %0.1f%%\n" $WriteRate

    printf " %-15s %5.1f%%\n" 'Cache Usage:' $CacheUsage 'Metadata Usage:' $MetaUsage 'Read Hit Rate:' $ReadRate 'Write Hit Rate:' $WriteRate
    echo
    echo " Demotions/Promotions/Dirty: $NrDemotions/$NrPromotions/$NrDirty"

    set -l i 15

    set -l FeatureArgs
    set -l end (math $i + $info[$i])
    if test $info[$i] != 0
        for i in (seq (math $i + 1) $end)
            set FeatureArgs $FeatureArgs $info[$i]
        end
        echo " Features: $FeatureArgs"
    end
    set i (math $end + 1)

    set -l CoreArgs
    set end (math $i + $info[$i] x 2)
    if test $info[$i] != 0
        echo " Core Args:"
        for i in (seq (math $i + 1) 2 $end)
            echo "   $info[$i] $info[$(math $i + 1)]"
        end
    end
    set i (math $end + 1)

    set -l PolicyArgs
    if test $i -lt (count $info)
        set end (math (count $info) - 1)
        if test $info[$i] != 0
            echo " Policy Args:"
            for i in (seq $i 2 $end)
                echo "   $info[$i] $info[$(math $i + 1)]"
            end
        end
    end
end
