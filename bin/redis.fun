:<<\_c
$PICASSO/core/bin/redis.fun = $PROOT/bin/host/fun/redis.fun

. $PICASSO/core/bin/redis.fun
_c

:<<\_s
alias redis-cli="redis-cli -h $REDIS_IP -p $REDIS_PORT"
_s


# ----------
:<<\_c
we are returning stdout; therefore, we cannot write anything else like _debug to it
_c

function _kv_get() {

#redis-cli -h $REDIS_IP -p $REDIS_PORT get $1
redis-cli -h $REDIS_IP -p $REDIS_PORT get $1 | tr -d '\n'
}
export -f _kv_get


# ----------
function _kv_set() {

redis-cli -h $REDIS_IP -p $REDIS_PORT set $1 $2
}
export -f _kv_set


# ----------
function _kv_delete() {

redis-cli -h $REDIS_IP -p $REDIS_PORT del $1
}
export -f _kv_delete


# ----------
function _kv_set_file() {

redis-cli -h $REDIS_IP -p $REDIS_PORT -x set $1 < $2
}
export -f _kv_set_file


# ----------
:<<\_c
_kv_get_file <key>  # returns a $(mktemp -t picasso.XXXXXXXX)
_kv_get_file <key> [file]
_c

function _kv_get_file() {

if [[ -n "$2" ]]; then

redis-cli -h $REDIS_IP -p $REDIS_PORT get $1 > $2

else

f=$(mktemp -t picasso.XXXXXXXX) || return 1

redis-cli -h $REDIS_IP -p $REDIS_PORT get $1 > $f

echo $f
fi

}
export -f _kv_get_file
