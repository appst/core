:<<\_c
. $PICASSO/core/bin/picasso-init.sh

[usage]

Host...
. $PICASSO/core/bin/picasso-init.sh $PROOT/bin/host/init.d/
PDEBUG=3 . $PICASSO/core/bin/picasso-init.sh $PWORK/$PID/.picasso/init.d/

Guest...
. $PICASSO/core/bin/picasso-init.sh $PGUEST/init.d/
_c

:<<\_c
environment files ($PGUEST/init.d/*) load before distro files ($OPT_PICASSO/core/init.d/*) so they can affect how the distro files load

/usr/bin/sort will list '.' files before numeric files
i want the numeric files to run before the '.' files, so i first load numeric files, and then the non-numeric files
_c

:<<\_c
$OPT_PICASSO/core/guest
/init.d/??-*.sh  # originate from basebox
$OPT_PICASSO/core/guest
/init.d/?-*.sh  # originate from subsequent provisioning

load provisioning environment
_c

(( PDEBUG < 3 )) || echo -e "\e[0;43m${BASH_SOURCE[0]}\e[0m"  #]

[[ -z "$1" ]] && { _alert '-z "$1"'; return 1; }


# _debug does not exist yet

# ----------
# *.env
for script in $(/usr/bin/find $1 -maxdepth 1 -name '*.env' \( -type l -o -type f \) | /usr/bin/sort); do
#for script in $(/usr/bin/find $PICASSO/core/init.d/ -maxdepth 1 -name '*.*' \( -type l -o -type f \) | /usr/bin/sort); do
#echo "asslalhasf script: $script"
#sleep 1
. $script || { echo ". $script"; sleep 10; exit 1; }
#echo "loading: $script done"
#sleep 1
done

# *.fun
for script in $(/usr/bin/find $1 -maxdepth 1 -name '*.fun' \( -type l -o -type f \) | /usr/bin/sort); do
#for script in $(/usr/bin/find $PICASSO/core/init.d/ -maxdepth 1 -name '*.*' \( -type l -o -type f \) | /usr/bin/sort); do
#echo "asslalhasf script: $script"
#sleep 5
. $script || { echo ". $script"; sleep 10; exit 1; }
#echo "loading: $script done"
#sleep 2
done

# _debug now exists

# numeric *.sh
for script in $(/usr/bin/find $1 -maxdepth 1 -name '[0-9]*.sh' \( -type l -o -type f \) | /usr/bin/sort); do
#_pdebug "loading: $script"
#sleep 1
. $script || { echo ". $script"; sleep 10; exit 1; }
#_pdebug "loading: $script done"
#sleep 1
done

# non-numeric *.sh
for script in $(/usr/bin/find $1 -maxdepth 1 -name '[^0-9]*.sh' \( -type l -o -type f \) | /usr/bin/sort); do
#_pdebug "loading: $script"
#sleep 1
. $script || { echo ". $script"; sleep 10; exit 1; }
#_pdebug "loading: $script done"
#sleep 1
done


#_debug "loading fini"


# ----------
(( PDEBUG < 3 )) || echo -e "\e[2;30;43m${BASH_SOURCE[0]}\e[0m"  #]

true
