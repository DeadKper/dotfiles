function lvc-info --wraps='dmsetup status' --description 'alias lvc-info=dmsetup status'
  set --local perm (sudo echo "y" || echo "n")

  if test $perm = n
    return 1
  end

  set -l info (sudo dmsetup status $argv | string split ' ')

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

  set -l MetaUsage (echo "scale=1;$NrMetadataBlocks[1] * 100 / $NrMetadataBlocks[2]" | bc)
  set -l CacheUsage ( echo "scale=1;($NrCacheBlocks[1] * 100) / $NrCacheBlocks[2]" | bc)
  echo " Cache Usage: $CacheUsage%"
  echo " Metadata Usage: $MetaUsage%"

  set -l ReadRate ( echo "scale=1;($NrReadHits * 100) / ($NrReadMisses + $NrReadHits)" | bc)
  set -l WriteRate ( echo "scale=1;($NrWriteHits * 100) / ($NrWriteMisses + $NrWriteHits)" | bc)
  echo " Read Hit Rate: $ReadRate%"
  echo " Write Hit Rate: $WriteRate%"
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
  set end (math $i + $info[$i] x 2 + 1)
  if test $info[$i] != 0
    echo " Core Args:"
    for i in (seq (math $i + 1) 2 $end)
      echo "   $info[$i] $info[$(math $i + 1)]"
    end
  end
  set i (math $end + 2)

  set -l PolicyArgs
  if test $i -lt (count $info)
    set end (math (math $i + $info[$i]) x 2)
    echo " Policy Args:"
    if test $info[$i] != 0
      for i in (seq (math $i + 1) 2 $end)
        echo "   $info[$i] $info[$(math $i + 1)]"
      end
    end
  end
end
