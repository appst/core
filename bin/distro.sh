# this is a bootstrapping network file only and need not reside on the target machine

# usage: direct all variables to the environment
# . /vagrant/.picasso/distro.sh

# or usage: direct all variables to a file that can subsequently loaded in the environment
# /vagrant/.picasso/distro.sh $PGUEST/init.d/0-distro.sh && . $PGUEST/init.d/0-distro.sh

:<<\_c

test...
$PICASSO/core/bin/distro.sh 0-distro.sh && cat 0-distro.sh

usage...
/vagrant/.picasso/distro.sh $PGUEST/init.d/0-distro.sh && . $PGUEST/init.d/0-distro.sh

$PICASSO/core/bin/distro.sh $PGUEST/init.d/00-distro.sh && . $PGUEST/init.d/00-distro.sh
_c


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
shopt -s expand_aliases  # declare before the aliases are declared

if [[ -n "$1" ]]; then
output=$1
> $output
alias __output='cat >> $output <<__output'
else
alias __output=''  # __
fi


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
arch=$(uname -m)
kernel=$(uname -r)

if [[ "$(expr substr $(echo $(uname -s) | tr -s '[:upper:]' '[:lower:]') 1 5)" == 'linux' ]]; then

# yes this is linux...

#if [[ "$kernel" =~ Microsoft ]]; then

if [[ -f "/etc/lsb-release" ]]; then

os=$(lsb_release -s -d)
export OS=ubuntu
export OSV=$(lsb_release -sr)

:<<\_s
# setting this is global and peristent - the drawback is that manual installs are also affected which is unexpected by the user
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
_s

elif [[ -f "/etc/debian_version" ]]; then

os="debian $(</etc/debian_version)"
export OS=debian

:<<\_s
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
_s

elif [[ -f "/etc/fedora-release" ]]; then

export OS=fedora

. /etc/fedora-release
export OSV=$VERSION_ID

export releasever=$(rpm -q --qf "%{version}\n" --whatprovides redhat-release)
export basearch=$(uname -m)

elif [[ -f "/etc/redhat-release" ]]; then

os=`cat /etc/redhat-release`
export OS=redhat

export releasever=$(rpm -q --qf "%{version}\n" --whatprovides redhat-release)
export basearch=$(uname -m)

elif [[ -f "/etc/arch-release" ]]; then

export OS=arch

else

export OS="$(echo $(uname -s) | tr -s '[:upper:]' '[:lower:]') $(uname -r)"

fi

export SYSD=$(systemctl --version 2> /dev/null | head -n1 | awk '{print $2}')

elif [[ "$(echo $(uname -o) | tr -s '[:upper:]' '[:lower:]')" == "cygwin" ]]; then

#export OS=cygwin
export OS=Windows_NT

elif [[ "$(echo $(uname -o) | tr -s '[:upper:]' '[:lower:]')" == "msys" ]]; then

#export OS=msys
export OS=Windows_NT

fi


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
#get_distro

__output
export OS=$OS
__output

[[ -n "$OSV" ]] && {
__output
export OSV=$OSV
__output
}

[[ -n "$SYSD" ]] && {
__output
export SYSD=$SYSD
__output
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
#shopt -s expand_aliases
:<<\_c
https://peteris.rocks/blog/quiet-and-unattended-installation-with-apt-get/
_c

case $OS in

arch)

__output
function _is_installed() { echo TODO; }

function _install() { 
if (( DEBUG == 0 )); then
sudo 1>/dev/null pacman --noconfirm -S "\$@"
elif (( DEBUG < -1 )); then
sudo &>/dev/null pacman --noconfirm -S "\$@"
elif (( DEBUG < -0 )); then
sudo 1>/dev/null 2>&1 pacman --noconfirm -S "\$@"
else
pacman --noconfirm -S "\$@"
fi
}
export -f _install
__output
;;


fedora)

__output
function _is_installed() { dnf -q list installed \$1; }
function _install() { 
if [[ ! -v DEBUG || \$DEBUG == 0 ]]; then
sudo dnf -qy install "\$@"
elif [[ ! -v DEBUG || \$DEBUG < -1 ]]; then
sudo &>/dev/null dnf -qy install "\$@"
elif [[ ! -v DEBUG || \$DEBUG < 0 ]]; then
sudo 1>/dev/null 2>&1 dnf -qy install "\$@"
else
sudo dnf -y install "\$@"
fi
}
export -f _install
__output
;;

debian|ubuntu)
# '-qq' implies '-y'
# http://askubuntu.com/questions/258219/how-do-i-make-apt-get-install-less-noisy

__output
function _is_installed() { &>/dev/null dpkg -s \$1; }

function _install() { 
if (( DEBUG == 0 )); then
sudo 1>/dev/null DEBIAN_FRONTEND=noninteractive apt-get -qy -o=Dpkg::Use-Pty=0 install "\$@"
elif (( DEBUG < -1 )); then
sudo &>/dev/null DEBIAN_FRONTEND=noninteractive apt-get -qqy -o=Dpkg::Use-Pty=0 install "\$@"
elif (( DEBUG < -0 )); then
sudo 1>/dev/null 2>&1 DEBIAN_FRONTEND=noninteractive apt-get -qqy -o=Dpkg::Use-Pty=0 install "\$@"
else
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o=Dpkg::Use-Pty=0 install "\$@"
fi
}
export -f _install
__output
:<<\_s
function _is_installed() { &>/dev/null dpkg-query -W -f='\''${Status} ${Version}\n'\'' \$1; }
_s

#function _is_installed() { dpkg -l \$1 | grep "ii"; }

#function _is_installed() { &>/dev/null dpkg-query -W \$1; }
#[[ \$DEBUG == 0 ]] \
#  && alias _install='sudo DEBIAN_FRONTEND=noninteractive apt-get -qqy install' \
#  || alias _install='sudo DEBIAN_FRONTEND=noninteractive apt-get -y install'
#[[ \$DEBUG == 0 ]] \
#  && alias _install='sudo DEBIAN_FRONTEND=noninteractive apt -qqy -o=Dpkg::Use-Pty=0 install' \
#  || alias _install='sudo DEBIAN_FRONTEND=noninteractive apt -y -o=Dpkg::Use-Pty=0 install'
#[[ -v DEBUG && \$DEBUG == 0 ]] && { sudo DEBIAN_FRONTEND=noninteractive apt-get -qqy -o=Dpkg::Use-Pty=0 install \$@; } || { sudo DEBIAN_FRONTEND=snoninteractive apt-get -qq -o=Dpkg::Use-Pty=0 install \$@; }

;;

esac



__output
function version { echo "\$@" | awk -F. '{ printf("%d%03d%03d%03d\n", \$1,\$2,\$3,\$4); }'; }
export -f version

true
__output


