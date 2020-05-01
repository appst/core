:<<\_c
papt install go
_c

:<<\_c
run script in this priority
1) local - $PICASSO/install/${dir}/${file}
2) remote - https://${FQDN}/${dir}/${file}
_c

function _install() {  # TODO: remove _PICASSO
_debug "1: $@"

local dir="${1%/*}"
local file="${1##*/}"
shift
_debug "dir: $dir, file: $file"

if [[ -f $PICASSO/install/${dir}/${file} ]]; then

_debug "offline: $PICASSO/install/${dir}/${file} $@"

if [[ "$1" == '.' || "$1" == 'source' ]]; then
shift
. $PICASSO/install/${dir}/${file} $@
else
$PICASSO/install/${dir}/${file} $@
fi

else

[[ -d $YOGA_TMPDIR ]] || export YOGA_TMPDIR=$(mktemp -d -t)

[[ -f $YOGA_TMPDIR/${dir}/${file} ]] || {

mkdir -p $YOGA_TMPDIR/$dir
wget -qP $YOGA_TMPDIR/${dir} https://${FQDN}/${dir}/${file} && chmod a+x $YOGA_TMPDIR/${dir}/${file}
}

_debug "online: https://${FQDN}/${dir}/${file} $@"

if [[ "$1" == '.' || "$1" == 'source' ]]; then
shift
. $YOGA_TMPDIR/${dir}/${file} $@
else
$YOGA_TMPDIR/${dir}/${file} $@
fi

fi

}

:<<\_x
_install /go/install.sh bin
_x


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
if [[ -n "$*" ]]; then  # do nothing if there are no parameters, that way we can still load the file and call its functions

local command=$1
shift

case $command in

install) _install $@ ;;

esac

fi
