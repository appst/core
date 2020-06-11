[[ -v _GENV_ ]] || . picasso-guest.sh
:<<\_c
this script receives arguments that Vagrant passes to it that originate within the Vagrantfile
in addition, Vagrant also sets the environment variable PROVISIONER=<name of current provisioning script file>
note that arguments are received as pairs (--<name>=[value])

[assumptions]
provisioner-env) may require vboxfs

[usage]
. picasso-provisioner.sh $@
...

_c

STAGE=${STAGE:-${DEFAULT_STAGE:-development}}

echo ssghfsdjfsdfds
DEBUG=3

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
PROVISIONER_ENV=$val
_info "Environment: $PROVISIONER_ENV"
_debug3 "$(<$PROVISIONER_ENV)"
. $PROVISIONER_ENV
;;

esac
done

set --  # clear script arguments to prevent re-entry and parameter propagation to sourced sub-scripts

}

_debug2

# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
_info "Provisioning '$PPROJ' with script '$PROVISIONER'"

_debug2 "_run_once_on_entry STAGE: $STAGE"

PICASSO=$OPT_PICASSO/v

case $STAGE in

development)

_debug2 "xcvbsdwyisdds MNT_V: $MNT_V, GIT_PICASSO: $GIT_PICASSO"

:<<\_j
if [[ -n "$MNT_V" ]]; then

_debug2 "MNT_V"

PICASSO=$MNT_V  # PICASSO=<source of Picasso's repo files>

else

[[ -z "$GIT_PICASSO" ]] && GIT_PICASSO=$OPT_PICASSO

_debug2 "GIT_PICASSO"

[[ -d "$GIT_PICASSO" ]] && {

_debug2

[[ -d $GIT_PICASSO/install ]] || {
1>/dev/null pushd $GIT_PICASSO
git submodule add $PDGIT/install.git
1>/dev/null popd
}

[[ -d "$GIT_PICASSO/custom" ]] || {
1>/dev/null pushd $GIT_PICASSO
sudo git submodule add $PDGIT/custom.git
1>/dev/null popd
}

}

PICASSO=$GIT_PICASSO  # PICASSO=<source of Picasso's repo files>

fi
_j

_debug "PICASSO: $PICASSO"
_debug3 "$(ls -la $PICASSO)"

1>/dev/null pushd $PICASSO

#if [[ -n "$MNT_V" ]]; then
#if [[ -d "$OPT_PICASSO/mnt" ]]; then
if [[ -d ".git" ]]; then

[[ -d ./install ]] || git submodule add $PDGIT/install.git

[[ -d ./custom ]] || sudo git submodule add $PDGIT/custom.git

#PICASSO=$GIT_PICASSO  # PICASSO=<source of Picasso's repo files>

else

#PICASSO=$MNT_V  # PICASSO=<source of Picasso's repo files>
#PICASSO=$OPT_PICASSO/v

[[ -d ./install ]] || git clone $PDGIT/install.git

[[ -d ./custom ]] || sudo clone $PDGIT/custom.git

fi

1>/dev/null popd

;;

production)

#[[ -d "$GIT_PICASSO" ]] && {
[[ -d "$PICASSO/.git" ]] && {

1>/dev/null pushd $PICASSO

[[ -d ./install ]] || git submodule add $PDGIT/install.git

[[ -d ./custom ]] || sudo git submodule add $PDGIT/custom.git

1>/dev/null popd

}

#PICASSO=$GIT_PICASSO  # PICASSO=<source of Picasso's repo files>
;;

*)
_error "Unknown STAGE: $STAGE"
;;

esac

#echo "PICASSO=$PICASSO" >> /etc/environment

_debug2 "PICASSO: $PICASSO"

[[ -d $PICASSO/custom ]] || _error "-d $PICASSO/custom"
