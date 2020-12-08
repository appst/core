:<<\_c
. $PICASSO/core/bin/picasso-init.sh

load provisioning environment

[usage]

Host...
. $PICASSO/core/bin/picasso-init.sh $PROOT/bin/host/init.d/
PDEBUG=3 . $PICASSO/core/bin/picasso-init.sh $PID_PICASSO/init.d/

Guest...
. $PICASSO/core/bin/picasso-init.sh $ROOT_PICASSO/init.d/
_c

:<<\_c
environment files ($ROOT_PICASSO/init.d/*) load before distro files ($PICASSO/core/init.d/*) so they can affect how the distro files load

/usr/bin/sort will list '.' files before numeric files
i want the numeric files to run before the '.' files, so i first load numeric files, and then the non-numeric files
_c

:<<\_c
$PICASSO/core/guest
/init.d/??-*.sh  # originate from basebox
$PICASSO/core/guest
/init.d/?-*.sh  # originate from subsequent provisioning
_c

:<<\_c
load order...
1) *.fun
2) *.env
3) '[0-9]*.sh'  # numeric
4) '[^0-9]*.sh'  # non-numeric
_c

(( PDEBUG < 3 )) || echo -e "\e[0;43m${BASH_SOURCE[0]}\e[0m $@"  #]

[[ -z "$1" ]] && { _alert '-z "$1"'; return 1; }


# _debug does not exist yet

echo lsdkfhjlkfjdljjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj

# *.fun
for script in $(/usr/bin/find $1 -maxdepth 1 -name '*.fun' \( -type l -o -type f \) | /usr/bin/sort); do
(( PDEBUG < 3 )) || echo ">>> script: $script"
#echo "loading: $script"
. $script || { echo ". $script"; sleep 10; exit 1; }
(( PDEBUG < 3 )) || echo "<<<: $script done"
done


# *.env
for script in $(/usr/bin/find $1 -maxdepth 1 -name '*.env' \( -type l -o -type f \) | /usr/bin/sort); do
(( PDEBUG < 3 )) || echo ">>> script: $script"
#echo "loading: $script"
. $script || { echo ". $script"; sleep 10; exit 1; }
(( PDEBUG < 3 )) || echo "<<<: $script done"
done

# _debug now exists


# numeric *.sh
for script in $(/usr/bin/find $1 -maxdepth 1 -name '[0-9]*.sh' \( -type l -o -type f \) | /usr/bin/sort); do
#_pdebug "loading: $script"
. $script || { echo ". $script"; sleep 10; exit 1; }
#_pdebug "loading: $script done"
done


# non-numeric *.sh
for script in $(/usr/bin/find $1 -maxdepth 1 -name '[^0-9]*.sh' \( -type l -o -type f \) | /usr/bin/sort); do
#_pdebug "loading: $script"
. $script || { echo ". $script"; sleep 10; exit 1; }
#_pdebug "loading: $script done"
done


# ----------
(( PDEBUG < 3 )) || echo -e "\e[2;30;43m${BASH_SOURCE[0]}\e[0m"  #]

true
