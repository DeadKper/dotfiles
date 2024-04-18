function matrix
    set -l chars "゠ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶヷヸヹヺ・ーヽヾヿ"
    # set -l chars 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()/'

    tput civis
    clear

    bash -c '
    function cleanup() {
      tput cnorm
    }

    trap cleanup EXIT
    while :; do
      echo $0 $1 $(( $RANDOM % $1 )) $(( $RANDOM % $2 ))
      sleep 0.04
    done | awk \'{
      characters="'$chars'";
      a[$3]=0;                        # array to store row index
      f[$3]=0;                        # flag to store show/erase
      for (x in a) {
        o=a[x];                       # get previous
        a[x]=a[x]+1;                  # increment previous and store
        chars[a[x] "," x] = substr(characters,$4,1)
        if (f[x] == 0) {
          printf "\033[%s;%sH\033[1;32m%s",o,x,chars[o "," x];
          printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,chars[a[x] "," x];
        }
        else {
          printf "\033[%s;%sH%s",o,x," ";
          printf "\033[%s;%sH%s\033[0;0H",a[x],x," ";
        }
        if (a[x] >= $1) {
          a[x]=0;
          if (f[x] == 0)
            f[x]=1;
          else
            f[x]=0;
        }
      }
    }\'' (tput lines) (tput cols) (string split '' $chars | count)
end
