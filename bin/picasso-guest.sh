# this file may be symlinked as follows: sudo ln -s $PICASSO/core/bin/picasso-guest.sh /etc/profile.d/picasso-guest.sh
# shebangs fail in /etc/profile.d/*
# iow: don't use a shebang in this file
# [usage]
# [[ -v _GENV_ ]] || . picasso-guest.sh

# non-interactive, non-login bash shells execute the contents of the file specified in $BASH_ENV
# automatically run non-interactively (ie: to run a sub-shell script)
# if [ -n "$BASH_ENV" ]; then . "$BASH_ENV"; fi
#export BASH_ENV=$PICASSO/core/bin/picasso-guest.sh

(( DEBUG < 3 )) || echo -e "\e[0;43m${BASH_SOURCE[0]}\e[0m"  #]


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
:<<\_c
_debug, et al may be loaded elsewhere, but by defining them here we are insured they are available
this script is common between picassorc and picasso-guest.sh
_c

shopt -s expand_aliases  # 36h bug

alias ~~~=': <<"~~~"'
alias __c=': <<"__c"'
alias __s=': <<"__s"'
alias __x=': <<"__x"'

function _debug() {
(( DEBUG > 0 )) && {
    local l=${#BASH_LINENO[@]}
    local f=${BASH_SOURCE[1]}
    f=$(basename ${f:-#})
    echo -e "\e[1;32m${f}:${BASH_LINENO[-$l]} $@\e[0m"  #]
  }
true
}
export -f _debug

function _debug2() {
(( DEBUG > 1 )) && {
   local l=${#BASH_LINENO[@]}
    local f=${BASH_SOURCE[1]}
    f=$(basename ${f:-#})
    echo -e "\e[1;32m${f}:${BASH_LINENO[-$l]} $@\e[0m"  #]
  } || true
}
export -f _debug2

function _debug3() {
(( DEBUG > 2 )) && {
   local l=${#BASH_LINENO[@]}
    local f=${BASH_SOURCE[1]}
    f=$(basename ${f:-#})
    echo -e "\e[1;32m${f}:${BASH_LINENO[-$l]} $@\e[0m"  #]
  } || true
}
export -f _debug3


# ----------
alias _alert='1>&2 echo -e "\e[1;41m${_TOP_:-$0}:$LINENO \e[0m"'  #]


# ----------
function _info() {
(( DEBUG > -1 || PDEBUG > -1 )) && {
echo -e "\e[0;32mINFO: $@ \e[0m"  #]
}
}
export -f _info


# ----------
function _warn() {
(( DEBUG < -1 )) ||  >&2 echo -e "\e[1;31mWARNING: $1 \e[0m"  #]
}
export -f _warn


# ----------
function _error() {
 >&2 echo -e "\e[1;31mERROR: $1 \e[0m"  #]
exit 1
}
export -f _error


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
# source guest environment

#echo ssssllljlosuosufs
#DEBUG=3

_debug "whoami: $(whoami), PWD: $PWD, HOME: $HOME"

_GENV_=true  # we don't export this value. in bash, sub-shells do not inherit aliases which we may have defined in init.d. to include those aliases in our environment we must reload our environment in sub-shells.

_debug "OPT_PICASSO: $OPT_PICASSO, MNT_V: $MNT_V, PICASSO: $PICASSO"

# this script may be run within a host context which has its own OPT_PICASSO
#OPT_PICASSO=${OPT_PICASSO:-/opt/picasso}; PGUEST=$PICASSO/core/guest
#PICASSO=${PICASSO:-/opt/picasso}; PGUEST=$PICASSO/core/guest

_debug "OPT_PICASSO: $OPT_PICASSO"

:<<\_c
$PICASSO/core/init.d/??-*.sh  # originate from basebox
$PICASSO/core/init.d/?-*.sh  # originate from subsequent provisioning

load provisioning environment
_c


# ----------
:<<\_c
provisioners write configuration to $PGUEST/init.d/
provisioners should not write to $PICASSO/core/init.d/ - they are distro files
_c

. $PICASSO/core/bin/picasso-init.sh $PGUEST/init.d/
#. $PICASSO/core/bin/picasso-init.sh $PGUEST/init.d/

for script in $(/usr/bin/find $PGUEST/network.d/ -maxdepth 1 -name '*.env' \( -type l -o -type f \) | /usr/bin/sort); do
_debug3 "sewttwree script: $script"
. $script || _error ". $script"
_debug3 "s0fs080 script: $script"
done

_debug3 "sdgsghweiytyt924"

# ----------
. $PICASSO/core/bin/picasso-init.sh $PICASSO/core/init.d/
#. $PICASSO/core/bin/picasso-init.sh $PICASSO/core/init.d/

_debug3 sdoww0w020002022002

# ----------
true


