#DEBUG=3
[[ -v _GENV_ ]] || . picasso-guest.sh
:<<\_c
NB: this file is part of 'core' which requires its own basebox - iow: changes to this file require a rebuild of the basebox

this script receives arguments that Vagrant passes to it that originate within the Vagrantfile
in addition, Vagrant also sets the environment variable PROVISIONER=<name of current provisioning script file>
note that arguments are received as pairs (--<name>=[value])

[assumptions]
provisioner-env) may require vboxfs

[usage]
. picasso-provisioner.sh #$@
...
_c

#TEST=true

STAGE=${STAGE:-${DEFAULT_STAGE:-production}}
TEST=${TEST:-false}

#echo ssghfsdjfsdfds
DEBUG=3
#echo "$(ip a)"
#echo "$(ip r)"
#echo "$(ping -c1 169.254.169.254)"
#_debug3 "$(curl -s http://169.254.169.254:8080/service/provisioner.env)"


# ----------
_debug "PROVISIONER_ENV: $PROVISIONER_ENV, PICASSO_METADATA_URL: $PICASSO_METADATA_URL"

:<<\_c
$ROOT_PICASSO/init.d/00-provider.env is already loaded and it may define $PROVISIONER_ENV
_c

[[ -n "$PROVISIONER_ENV" ]] && {

[[ -f $ROOT_PICASSO/provisioner.env ]] || {

case "$METADATA_SOURCE" in

virtualbox)
_info "Loading metadata from /vagrant/$PROVISIONER_ENV"
cp /vagrant/$PROVISIONER_ENV $ROOT_PICASSO/provisioner.env
;;

cloudinit|*)
_info "Loading metadata from $PICASSO_METADATA_URL/$PROVISIONER_ENV"
curl -s -o $ROOT_PICASSO/provisioner.env $PICASSO_METADATA_URL/$PROVISIONER_ENV
;;

esac

}

. $ROOT_PICASSO/provisioner.env

}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
_debug3 "@ $@"

[[ -n "$@" ]] && {

. $PICASSO/core/bin/longopts.sh
_debug3 "longopts: ${longopts[@]}"

for opt in "${!longopts[@]}"; do  # keys
val=${longopts[$opt]}
_debug3 "opt: $opt, val: $val"

case $opt in

provisioner)
provisioner=$val
;;

provisioner-env)
_info "Environment: $val"

PROVISIONER_ENV=$val
_info "Loading metadata from $PROVISIONER_ENV"

  if [[ "$val" =~ (^| )http:// ]]; then
    curl -s -o $ROOT_PICASSO/provisioner.env $val
    . $ROOT_PICASSO/provisioner.env
  elif [[ -f "$val" ]]; then
    PROVISIONER_ENV=$val
_debug3 "$(<$PROVISIONER_ENV)"
    . $PROVISIONER_ENV
fi

;;

esac

done

_debug3

set --  # clear script arguments to prevent re-entry and parameter propagation to sourced sub-scripts

}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
_info "Provisioning '$PPROJ' with script '$PROVISIONER'"

_debug3 "_run_once_on_entry STAGE: $STAGE"

case $STAGE in

development|production)

_debug3 "xcvbsdwyisddsz MNT_V: $MNT_V"

if [[ -n "$MNT_V" ]]; then

_debug3 "$(ls -l $MNT_V)"
_debug3 "$(ls -l $PICASSO)"

:<<\_c
if the directory already exists, then it has already been initialized
it may already have been initialized within the basebox
or, it may already have been initialized by earlier chained provisioning

the question of whether or not to overwrite the existing directory arises
if we don't overwrite, then a new basebox must be used that contains the desired files?
if we do overwrite, then how do we do so only once and not by each chained provisioner?

philosophy...
that done within the basebox remains, and therefore, during basebox building, we don't initialize these directories
iow: $PICASSO/core is pre-initialized within the basebox and does not get updated - use the basebox with the 'core' files you need, because at provision time you cammot modify 'core' files
other modules are installed on a first come, first served, basis
first come first served makes sense during provisioning, since the files should not change mid-provisioning
_c
[[ -d "$PICASSO/install" ]] || {
_debug3
sudo mkdir $PICASSO/install
sudo cp -fr $MNT_V/install/* $PICASSO/install/
}

[[ -d "$PICASSO/custom" ]] || {
_debug3
sudo mkdir $PICASSO/custom
sudo cp -fr $MNT_V/custom/* $PICASSO/custom/
}

elif [[ -n "$PDGIT" ]]; then

_debug3 "_install git"

_is_installed git || _install git

_debug3 "PICASSO: $PICASSO"
_debug3 "$(ls -la $PICASSO)"

1>/dev/null pushd $PICASSO

if [[ -d ".git" ]]; then

[[ -d "./install" ]] || sudo git submodule add $PDGIT/install.git
[[ -d "./custom" ]] || sudo git submodule add $PDGIT/custom.git

else

[[ -d "./install" ]] || sudo git clone $PDGIT/install.git
[[ -d "./custom" ]] || sudo git clone $PDGIT/custom.git

fi

1>/dev/null popd

fi

;;

*)
_alert "Skipping STAGE: $STAGE"
;;

esac

_debug3 "PICASSO: $PICASSO"

$TEST && {
[[ -d $PICASSO/install ]] || _error "-d $PICASSO/install"
[[ -d $PICASSO/custom ]] || _error "-d $PICASSO/custom"
} #$TEST
