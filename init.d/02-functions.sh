(( PDEBUG < 3 )) || echo -e "\e[0;43m>>> ${BASH_SOURCE[0]}\e[0m"  #]

:<<\_c
whenever bash starts executing the conditional in an if statement it disables the errexit feature. It leaves this disabled until the conditional has been evaluated.
https://delx.net.au/blog/2016/03/safe-bash-scripting-set-e-is-not-enough/
_c


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
:<<\_c
_indirect_variable_exists IS_OPENSTACK
# bash returns this: false or true/undefined
# we want bash to return this: false/undefined or true
_c

:<<\_c
export IS_OPENSTACK=true
$IS_OPENSTACK && echo test

export IS_OPENSTACK=false
$IS_OPENSTACK && echo test

unset IS_OPENSTACK
$IS_OPENSTACK && echo test

if _indirect_variable_exists IS_OPENSTACK; then
echo test
fi
_c

:<<\_s
alias _indirect_variable_exists='[[ -v IS_OPENSTACK ]] && $IS_OPENSTACK'

export IS_OPENSTACK=true
_indirect_variable_exists IS_OPENSTACK && echo test
if _indirect_variable_exists IS_OPENSTACK; then
echo test
fi

export IS_OPENSTACK=false
_indirect_variable_exists IS_OPENSTACK && echo test
if _indirect_variable_exists IS_OPENSTACK; then
echo test
fi

unset IS_OPENSTACK
_indirect_variable_exists IS_OPENSTACK && echo test
if _indirect_variable_exists IS_OPENSTACK; then
echo test
fi
_s


# if we use functions like is_openstack and is_devstack, that requires all the functions to be declared whether they are used or not

# instead we create a generic function that tests our variable's existence and value

function _indirect_variable_exists() { [[ -v $1 ]] && ${!1}; }
export -f _indirect_variable_exists

:<<\_x
export IS_TEST=true
_indirect_variable_exists IS_TEST && echo test

export IS_TEST=false
_indirect_variable_exists IS_TEST && echo test

unset IS_TEST
_indirect_variable_exists IS_TEST && echo test
_x


# ----------
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }
export -f version


# ----------
_debug "DISTRO_NAME: $DISTRO_NAME"

case $DISTRO_NAME in

ubuntu)
#shopt -s expand_aliases
#alias _install='sudo apt-get -y install'
function _install() {
sudo apt-get -y install $@ 1>/dev/null
}
export -f _install

function _is_installed() {
$>/dev/null dpkg -l $1
}
export -f _is_installed

;;

esac


# ---------- ---------- ---------- ---------- ----------
(( PDEBUG < 3 )) || echo -e "\e[2;30;43m<<< ${BASH_SOURCE[0]}\e[0m"  #]

true
