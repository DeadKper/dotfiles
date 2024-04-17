function matrix
    set -l chars "゠ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶヷヸヹヺ・ーヽヾヿ"

    echo -e "\e[1;40m"
    tput civis

    clear

    bash -c '
    function cleanup() {
      tput cnorm
    }

    trap cleanup EXIT
    while :; do
      echo $0 $1 $(( $RANDOM % $1 )) $(( $RANDOM % $2 ))
      sleep 0.05
    done | awk \'{
      characters="'$chars'";
      c=$4;                           # random index
      letter=substr(characters,c,1);  # random letter
      a[$3]=0;                        # array to store row index
      f[$3]=0;                        # flag to store show/erase
      for (x in a) {
        o=a[x];                       # get previous
        a[x]=a[x]+1;                  # increment previous and store
        if (f[x] == 0) {
          printf "\033[%s;%sH\033[2;32m%s",o,x,letter;
          printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;
        }
        else {
          printf "\033[%s;%sH\033[2;32m%s",o,x," ";
          printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x," ";
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
