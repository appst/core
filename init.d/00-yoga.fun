:<<\_c
. $PICASSO/core/init.d/00-yoga.fun aka $PROOT/bin/repo/v/core/init.d/00-yoga.fun

export DEBUG=-1  # silent & no testing
export DEBUG=0  # standard testing
export DEBUG=1  # high level debug testing
export DEBUG=2  # higher level debug testing
export DEBUG=3  # highest level debug testing
_c


(( PDEBUG < 3 )) || echo -e "\e[0;43m>>> ${BASH_SOURCE[0]}\e[0m"  #]


:<<\_j
shopt -s expand_aliases  # 36hr bug

alias ~~~=': <<"~~~"'
alias ~~=': <<"~~"'  # fedora was chopping off our first tilde, so this insures we still ignore our blocked out script
alias __c=': <<"__c"'
alias __s=': <<"__s"'
alias __t=': <<"__t"'
alias __x=': <<"__x"'
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

#&>/dev/null alias __c || . $PGUEST/init.d/00-yoga.fun  # __c
_j

:<<\_c
printf '[FAIL] 00-bash-aliases.sh - %s%s%s not interpreted as a comment\n' '_' '_' 'c'
exit 1  # break out
_c

function _debug() {
(( DEBUG > 0 || PDEBUG > 0 )) && {
  local l=${#BASH_LINENO[@]}
  local f=${BASH_SOURCE[1]}
  f=$(basename ${f:-#})
  echo -e "\e[1;32m${f}:${BASH_LINENO[-$l]} $@ \e[0m"  #]
  }
}
export -f _debug


function _debug2() {
(( DEBUG > 1 || PDEBUG > 1 )) && {
  local l=${#BASH_LINENO[@]}
  local f=${BASH_SOURCE[1]}
  f=$(basename ${f:-#})
  echo -e "\e[0;32m${f}:${BASH_LINENO[-$l]} $@ \e[0m"  #]
}
}
export -f _debug2


function _debug3() {
(( DEBUG > 2 || PDEBUG > 2 )) && {
  local l=${#BASH_LINENO[@]}
  local f=${BASH_SOURCE[1]}
  f=$(basename ${f:-#})
  echo -e "\e[0;32m${f}:${BASH_LINENO[-$l]} $@ \e[0m"  #]
}
}
export -f _debug3


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


function _info() {
(( DEBUG > -1 || PDEBUG > -1 )) && {
echo -e "\e[0;32mINFO: $@ \e[0m"  #]
}
}
export -f _info


function _warn() {
(( DEBUG < -1 )) ||  >&2 echo -e "\e[1;31mWARNING: $1 \e[0m"  #]
}
export -f _warn


function _alert() {
  1>&2 echo -e "\e[1;41m${_TOP_:-$0}:$LINENO \e[0m"  #]
}
export -f _alert


function _error() {
  1>&2 echo -e "\e[1;31mERROR: $1 \e[0m"  #]
sleep 60
exit 1
}
export -f _error


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
