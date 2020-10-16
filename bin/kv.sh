:<<\_c
$PICASSO/core/bin/kv.sh

initializes the KV runtime of the guest

prov-sys.sh {
. $PICASSO/core/bin/kv.sh
[[ -n "$MEMBER_PQDN" ]] && {
#[[ -n "$KV_STORE" ]] && ln -s $PICASSO/core/bin/kv.fun $ROOT_PICASSO/bin/kv.fun
}
}
. picasso-guest.sh {
}
_c
:<<\_c
kv.${FED_PQDN} is registered in dns as the Kv endpoint
redis.${FED_PQDN} would work as well; however, the generic 'kv' enables us to use any KV_STORE at kv.${FED_PQDN}
_c

_debug2 "KV_STORE: $KV_STORE"

#[[ -v KV_STORE ]] || return 1
KV_STORE=${KV_STORE:-redis}  # redis|consul|etcd...

case $KV_STORE in

consul)
# . $PICASSO/core/bin/consul.fun
cp $PICASSO/core/bin/consul.fun $ROOT_PICASSO/bin/

cat > $ROOT_PICASSO/init.d/consul.env <<!
KV_STORE=$KV_STORE
KV_IP=${KV_IP:-kv.${FED_PQDN}}
KV_PORT=${KV_PORT:-$CONSUL_PORT}

. $ROOT_PICASSO/bin/consul.fun
!
#KV_IP=${KV_IP:-consul.${FED_PQDN}}
;;

redis)
# . $PICASSO/core/bin/redis.fun
cp $PICASSO/core/bin/redis.fun $ROOT_PICASSO/bin/

cat > $ROOT_PICASSO/init.d/redis.env <<!
KV_STORE=$KV_STORE
KV_IP=${KV_IP:-kv.${FED_PQDN}}
KV_PORT=${KV_PORT:-$REDIS_PORT}

. $ROOT_PICASSO/bin/redis.fun
!
#KV_IP=${KV_IP:-redis.${FED_PQDN}}
;;

*) return 1;;
esac

true
