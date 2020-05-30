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

STAGE=${STAGE:-development}


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

case $STAGE in

development)

_debug2 "xcvbsdwyisdds MNT_PICASSO: $MNT_PICASSO, GIT_PICASSO: $GIT_PICASSO"

if [[ -n "$MNT_PICASSO" ]]; then

_debug2 "MNT_PICASSO"

PICASSO=$MNT_PICASSO  # PICASSO=<source of Picasso's repo files>

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

;;

production)

[[ -d "$GIT_PICASSO" ]] && {

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
;;

*)
_error "Unknown STAGE: $STAGE"
;;

esac

#echo "PICASSO=$PICASSO" >> /etc/environment

_debug2 "PICASSO: $PICASSO"

[[ -d $PICASSO/custom ]] || _error "-d $PICASSO/custom"
