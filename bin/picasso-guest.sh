# this file may be symlinked as follows: sudo ln -s $PICASSO/core/bin/picasso-guest.sh /etc/profile.d/picasso-guest.sh
# shebangs fail in /etc/profile.d/*
# iow: don't use a shebang in this file
# [usage]
# [[ -v _GENV_ ]] || . picasso-guest.sh

# non-interactive, non-login bash shells execute the contents of the file specified in $BASH_ENV
# automatically run non-interactively (ie: to run a subshell script)
# if [ -n "$BASH_ENV" ]; then . "$BASH_ENV"; fi
#export BASH_ENV=$PICASSO/core/bin/picasso-guest.sh

(( DEBUG < 3 )) || echo -e "\e[0;43m${BASH_SOURCE[0]}\e[0m"  #]


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
:<<\_c
_debug, et al may be loaded elsewhere, but by defining them here we are insured they are available
this script is common between picassorc and picasso-guest.sh
_c

shopt -s expand_aliases  # 36h bug

function _debug() {
(( DEBUG > 0 )) && {
    local l=${#BASH_LINENO[@]}
    local f=${BASH_SOURCE[1]}
    f=$(basename ${f:-#})
    echo -e "\e[1;32m${f}:${BASH_LINENO[-$l]} $@\e[0m"  #]
    [[ -v PICASSO_LOG ]] && echo "${f}:${BASH_LINENO[-$l]} $@" >> $PICASSO_LOG
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
    [[ -v PICASSO_LOG ]] && echo "${f}:${BASH_LINENO[-$l]} $@" >> $PICASSO_LOG
  } || true
}
export -f _debug2

function _debug3() {
(( DEBUG > 2 )) && {
   local l=${#BASH_LINENO[@]}
    local f=${BASH_SOURCE[1]}
    f=$(basename ${f:-#})
    echo -e "\e[1;32m${f}:${BASH_LINENO[-$l]} $@\e[0m"  #]
    [[ -v PICASSO_LOG ]] && echo "${f}:${BASH_LINENO[-$l]} $@" >> $PICASSO_LOG
  } || true
}
export -f _debug3


# ----------
#alias _alert='1>&2 echo -e "\e[1;41m${_TOP_:-$0}:$LINENO \e[0m"'  #]
function _alert() {
  1>&2 echo -e "\e[1;41m${_TOP_:-$0}:$LINENO $1 \e[0m"  #]
  [[ -v PICASSO_LOG ]] && echo "${_TOP_:-$0}:$LINENO $1" >> $PICASSO_LOG
}
export -f _alert


# ----------
function _info() {
(( DEBUG > -1 || PDEBUG > -1 )) && {
echo -e "\e[0;32mINFO: $@ \e[0m"  #]
    [[ -v PICASSO_LOG ]] && echo "INFO: $@" >> $PICASSO_LOG
}
}
export -f _info


# ----------
function _warn() {
(( DEBUG < -1 )) ||  >&2 echo -e "\e[1;31mWARNING: $1 \e[0m"  #]
    [[ -v PICASSO_LOG ]] && echo "WARNING: $1" >> $PICASSO_LOG
}
export -f _warn


# ----------
function _error() {
 >&2 echo -e "\e[1;31mERROR: $1 \e[0m"  #]
    [[ -v PICASSO_LOG ]] && echo "ERROR: $1" >> $PICASSO_LOG
exit 1
}
export -f _error


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
# source guest environment

#echo ssssllljlosuosufs
#DEBUG=3

_debug3 "whoami: $(whoami), PWD: $PWD, HOME: $HOME"

_GENV_=true  # we don't export this value. in bash, subshells do not inherit aliases which we may have defined in init.d. to include those aliases in our environment we must reload our environment in subshells.
#declare -r -g _GENV_=1

_debug3 "ROOT_PICASSO: $ROOT_PICASSO, MNT_V: $MNT_V, PICASSO: $PICASSO"

# this script may be run within a host context which has its own ROOT_PICASSO
#ROOT_PICASSO=${ROOT_PICASSO:-/opt/picasso}; PGUEST=$PICASSO/core/guest
#PICASSO=${PICASSO:-/opt/picasso}; PGUEST=$PICASSO/core/guest

_debug3 "ROOT_PICASSO: $ROOT_PICASSO"

:<<\_c
$PICASSO/core/init.d/??-*.sh  # originates from basebox
$PICASSO/core/init.d/?-*.sh  # originates from subsequent provisioning

load provisioning environment
_c


# ----------
:<<\_c
provisioners write configuration to $ROOT_PICASSO/init.d/
provisioners should not write to $PICASSO/core/init.d/ - they are distro files
_c

. $PICASSO/core/bin/picasso-init.sh $PICASSO/core/init.d/  # TODO: deprecate - why two sources + move fix prov-sys

. $PICASSO/core/bin/picasso-init.sh $ROOT_PICASSO/init.d/

:<<\_s
for script in $(/usr/bin/find $PICASSO/core/guest/network.d/ -maxdepth 1 -name '*.env' \( -type l -o -type f \) | /usr/bin/sort); do
#_debug3 "sewttwree script: $script"
. $script || _error ". $script"
#_debug3 "s0fs080 script: $script"
done
_s

_debug3 "sdgsghweiytyt924"

# ----------
#. $PICASSO/core/bin/picasso-init.sh $PICASSO/core/init.d/


# ----------
true


