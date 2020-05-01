:<<\_c
. $OPT_PICASSO/core/init.d/00-yoga.fun

&>/dev/null alias __c || . $PGUEST/init.d/00-yoga.fun  # __c
_c


#export DEBUG=0  # -1: silent & no testing, 0: standard testing, 1: highest level debug testing, 2: next highest...

(( PDEBUG < 3 )) || echo -e "\e[0;43m>>> ${BASH_SOURCE[0]}\e[0m"  #]


alias ~~=': <<"~~"'  # fedora was chopping off our first tilde, so this insures we still ignore our blocked out script

alias __t=': <<"__t"'
alias __t-='alias __t=": <<\"__t\""'  # __t
alias __t+='alias __t=""'

:<<\_c
printf '[FAIL] 00-bash-aliases.sh - %s%s%s not interpreted as a comment\n' '_' '_' 'c'
exit 1  # break out
_c

/usr/bin/env | /bin/grep -q '^TEST=' && {
if [[ $TEST -lt 0 ]]; then  # no testing
alias __t=': <<"__t"'
elif [[ $TEST -eq 0 ]]; then  # standard testing
alias __t=''  # __t
fi
}



# ----------
function _debug_network() {
  (( DEBUG_NETWORK > 0 )) && {
    local l=${#BASH_LINENO[@]}
    local f=${BASH_SOURCE[1]}
    f=$(basename ${f:-#})
    echo -e "\e[1;32m${f}:${BASH_LINENO[-$l]} $@ \e[0m"  #]
  } || true
}
export -f _debug_network

:<<\_x
DEBUG_NETWORK=1 _debug_network "Hello, World!"
_x


# ----------
(( PDEBUG < 3 )) || echo -e "\e[2;30;43m<<< ${BASH_SOURCE[0]}\e[0m"  #]

true
