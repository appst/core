:<<\_c
$PICASSO/core/bin/kv.fun

we want to load this file from init.d, which means it will load whether there is a kv store or not

there are three conditions
KV_STORE undefined - that's cool, we presume provisioning does not need it - return 0
KV_STORE defined and not empty - load the appropriate handler - return 0
KV_STORE defined and empty or not a valid handler - return 1
_c

[[ -v KV_STORE ]] || return 1

case $KV_STORE in
consul) . $PICASSO/core/bin/consul.fun;;
redis) . $PICASSO/core/bin/redis.fun;;
*) return 1;;
esac

return 0
