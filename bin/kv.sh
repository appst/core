:<<\_c
$PICASSO/core/bin/kv.sh

initializes the KV runtime of the guest

prov-sys.sh {
. $PICASSO/core/bin/kv.sh
}
_c

_debug2 "KV_STORE: $KV_STORE"

#[[ -v KV_STORE ]] || return 1
KV_STORE=${KV_STORE:-redis}

case $KV_STORE in

consul)
# . $PICASSO/core/bin/consul.fun
cp $PICASSO/core/bin/consul.fun $OPT_PICASSO/bin/

cat > $OPT_PICASSO/init.d/consul.env <<!
KV_STORE=$KV_STORE
KV_IP=${KV_IP:-kv.${FED_PQDN}}
KV_PORT=${KV_PORT:-$CONSUL_PORT}

. $OPT_PICASSO/bin/consul.fun
!
;;

redis)
# . $PICASSO/core/bin/redis.fun
cp $PICASSO/core/bin/redis.fun $OPT_PICASSO/bin/

cat > $OPT_PICASSO/init.d/redis.env <<!
KV_STORE=$KV_STORE
KV_IP=${KV_IP:-kv.${FED_PQDN}}
KV_PORT=${KV_PORT:-$REDIS_PORT}

. $OPT_PICASSO/bin/redis.fun
!
;;

*) return 1;;
esac

#return 0
true
