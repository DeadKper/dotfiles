function lsblk --description 'alias lsblk=lsblk -o NAME,FSTYPE,SIZE,FSAVAIL,FSUSE%,MOUNTPOINTS'
    if test -z "$argv"
        command lsblk -o NAME,FSTYPE,SIZE,FSAVAIL,FSUSE%,MOUNTPOINTS
    else
        command lsblk $argv
    end
end
