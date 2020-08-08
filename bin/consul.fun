:<<\_c
. $PICASSO/core/bin/consul.fun
_c

1>/dev/null which curl || _install curl


# ----------
#CONSUL_HTTP_ADDR=${CONSUL_HTTP_ADDR:-http://$FED_PQDN:8500}
#CONSUL_PROXY_ADDR=${CONSUL_PROXY_ADDR:-http://$FED_PQDN/consul}  # reverse proxy
:<<\_j
[[ -z "$CONSUL_PROXY_ADDR" ]] && {

_alert "CONSUL_PROXY_ADDR" $CONSUL_PROXY_ADDR"

FED_PQDN=${FED_PQDN:-$GENESIS_PQDN}

[[ -z "$FED_PQDN" ]] && _error '-z "$FED_PQDN"'

:<<\_s
. $PICASSO/core/bin/dns.fun

ip=$(_dns_get consul.$FED_PQDN)

CONSUL_PROXY_ADDR="http://${ip}${CONSUL_PROXY_HTTP}"  # reverse proxy
_s

CONSUL_PROXY_HTTP=${CONSUL_PROXY_HTTP:-/kv}
CONSUL_PROXY_ADDR=http://${FED_PQDN}${CONSUL_PROXY_HTTP}
}
_j


# ----------
:<<\_c
sanity check
_c

function _main() {

if [[ -n "$CONSUL_CACERT_PATH" ]]; then
rv=$(curl --cacert $CONSUL_CACERT_PATH --cert $CONSUL_CLIENT_CERT_PATH --key $CONSUL_CLIENT_KEY_PATH -s -o /dev/null --connect-timeout 2 --write-out '%{http_code}\n' $CONSUL_PROXY_ADDR/v1/status/leader)
[[ $? -eq 0 && "$rv" == "200" ]] || return $rv
else
rv=$(curl -s -o /dev/null --connect-timeout 2 --write-out '%{http_code}\n' $CONSUL_PROXY_ADDR/v1/status/leader)
[[ $? -eq 0 && "$rv" == "200" ]] || return $rv
fi

return 0

}; _main


# ----------
:<<\_c
we are returning stdout; therefore, we cannot write anything else like _debug to it
_c

function _kv_get() {
local key=$1

#[[ -z "$CONSUL_PROXY_ADDR" ]] && { _alert "Missing CONSUL_PROXY_ADDR"; return 1; }

#_debug3 "curl -sX GET $CONSUL_PROXY_ADDR/v1/kv/$key?raw" 1>2  # we are returning stdout so we can't send anything else to it

#curl -4 -sX GET $CONSUL_PROXY_ADDR/v1/kv/$key?raw
if [[ -n "$CONSUL_CACERT_PATH" ]]; then
curl --cacert $CONSUL_CACERT_PATH --cert $CONSUL_CLIENT_CERT_PATH --key $CONSUL_CLIENT_KEY_PATH \
  -sX GET $CONSUL_PROXY_ADDR/v1/kv/$key?raw
else
curl \
  -sX GET $CONSUL_PROXY_ADDR/v1/kv/$key?raw
fi
#wget -qO- $CONSUL_PROXY_ADDR/v1/kv/$key?raw
}
export -f _kv_get

:<<\_x
curl $CONSUL_PROXY_ADDR/v1/kv/DNS_KEY?raw
curl -X GET $CONSUL_PROXY_ADDR/v1/kv/DNS_KEY?raw
curl -sX GET $CONSUL_PROXY_ADDR/v1/kv/$key?raw
curl --resolve $nameserver -X GET $CONSUL_PROXY_ADDR/v1/kv/$key?raw
_x

:<<\_x
. $PWORK/$PID/.picasso/init.sh
curl $CONSUL_PROXY_ADDR/v1/kv/DNS_KEY?raw

#. $PICASSO/core/bin/consul.fun
_kv_get OS_AUTH_URL
_x


# ----------
:<<\__s
function _kv_set() {
local key=$1
local value=$2

_info "vault kv put secret/$PID identity=$IDENTITY_MANAGEMENT_IP"

1>/dev/null vault kv put secret/$PID identity=$IDENTITY_MANAGEMENT_IP
identity_ip=$(vault kv get -field identity -format table secret/$PID)
[[ $identity_ip == $IDENTITY_MANAGEMENT_IP ]] || _error "identity_ip/$identity_ip != IDENTITY_MANAGEMENT_IP/$IDENTITY_MANAGEMENT_IP"
}
__s

function _kv_set() {
local key=$1
local value=$2

#[[ -z "$CONSUL_PROXY_ADDR" ]] && { _alert "Missing CONSUL_PROXY_ADDR"; return 1; }

_debug3 "curl -sX PUT -d \"$value\" $CONSUL_PROXY_ADDR/v1/kv/$key"

#curl -4 -sX PUT -d "$value" $CONSUL_PROXY_ADDR/v1/kv/$key
#1>/dev/null curl -sX PUT -d "$value" $CONSUL_PROXY_ADDR/v1/kv/$key
if [[ -n "$CONSUL_CACERT_PATH" ]]; then
rv=$(
curl --cacert $CONSUL_CACERT_PATH --cert $CONSUL_CLIENT_CERT_PATH --key $CONSUL_CLIENT_KEY_PATH \
  -sX PUT -d "$value" $CONSUL_PROXY_ADDR/v1/kv/$key
)
else
rv=$(
curl \
  -sX PUT -d "$value" $CONSUL_PROXY_ADDR/v1/kv/$key
)
fi
x=$?
[[ $x == 0 ]] || _alert "_kv_set returned x: $x, rv: $rv"

#wget --post-data="$value" $CONSUL_PROXY_ADDR/v1/kv/$key  # requires newish wget
}
export -f _kv_set

#curl -sX PUT -d "$value" $CONSUL_PROXY_ADDR/v1/kv/$key
#curl --resolve $nameserver -X PUT -d "$value" $CONSUL_PROXY_ADDR/v1/kv/$key
:<<\_x
KV_PATH=/kv
CONSUL_PROXY_ADDR=${CONSUL_PROXY_ADDR:-http://${FED_PQDN}${KV_PATH}}  # reverse proxy
key=key
value=value
curl -sX PUT -d "$value" $CONSUL_PROXY_ADDR/v1/kv/$key
_x
:<<\_x
. openrc admin admin dev
_kv_set os_auth_url $OS_AUTH_URL
_x

function _kv_delete() {
local key=$1

_debug3 "curl -sX DELETE $CONSUL_PROXY_ADDR/v1/kv/$key"

if [[ -n "$CONSUL_CACERT_PATH" ]]; then
rv=$(
curl --cacert $CONSUL_CACERT_PATH --cert $CONSUL_CLIENT_CERT_PATH --key $CONSUL_CLIENT_KEY_PATH \
  -sX DELETE $CONSUL_PROXY_ADDR/v1/kv/$key
)
else
rv=$(
curl \
  -sX DELETE $CONSUL_PROXY_ADDR/v1/kv/$key
)
fi
x=$?
[[ $x == 0 ]] || _alert "_kv_delete returned x: $x, rv: $rv"
}
export -f _kv_delete


# ----------
function _kv_set_file() {
local key=$1
local file=$2
local type=${3:-application/zip}

_debug "CONSUL_PROXY_ADDR: $CONSUL_PROXY_ADDR"

_debug3 "curl -sX PUT -d \"$file\" $CONSUL_PROXY_ADDR/v1/kv/$key"

#curl -4 $CONSUL_PROXY_ADDR/v1/kv/$key --upload-file $file
#r=$(curl -s --upload-file $file $CONSUL_PROXY_ADDR/v1/kv/$key -H "Content-Type: $type" -H 'Expect:')
if [[ -n "$CONSUL_CACERT_PATH" ]]; then
r=$(
curl --cacert $CONSUL_CACERT_PATH --cert $CONSUL_CLIENT_CERT_PATH --key $CONSUL_CLIENT_KEY_PATH \
  -s --upload-file $file $CONSUL_PROXY_ADDR/v1/kv/$key -H "Content-Type: $type" -H 'Expect:'
)
else
r=$(
curl \
  -s --upload-file $file $CONSUL_PROXY_ADDR/v1/kv/$key -H "Content-Type: $type" -H 'Expect:'
)
fi

[[ "$r" == 'true' ]] || _alert "_kv_set_file returned r: $r"

#wget --post-file=$file $CONSUL_PROXY_ADDR/v1/kv/$key
}
export -f _kv_set_file

#curl -sX PUT -d "$(<$file)" $CONSUL_PROXY_ADDR/v1/kv/$key
:<<\_x
echo "hello world!" > ./bar
wget --post-file=./bar $CONSUL_PROXY_ADDR/v1/kv/foo

_kv_set_file foo ./bar
_x

:<<\_j
ret=$(curl -sX PUT -d "$value" $CONSUL_PROXY_ADDR/v1/kv/$key)
echo "ret: $ret"
if [[ $? -eq 0 && $ret == 'true' ]]; then

# consul kv get $key
result=$(curl -sX GET $CONSUL_PROXY_ADDR/v1/kv/$key?raw)
echo "?: $?, result: $result"
if [[ $? -eq 0 && $result == $value ]]; then
_info "Consul [OK]"
else
_error "Consul: $result != $value"
fi
else
_error "Consul: $ret != 'true'"
fi
_j

# ----------
:<<\_c
. $PID_PICASSO/init.d/consul.env
. $PICASSO/core/bin/consul.fun
_kv_set_file SSH_PRIVATE_KEY $SSH_PRIVATE_KEY
_kv_get_file SSH_PRIVATE_KEY
_c
:<<\_c
_kv_get_file <key>  # returns a $(mktemp -t picasso.XXXXXXXX)
_kv_get_file <key> [file]
_c

function _kv_get_file() {
local key=$1
if [[ -n "$2" ]]; then
local file=$2
else
local file=$(mktemp -t picasso.XXXXXXXX) || return 1
fi
local type=${3:-application/zip}
:<<\_x
key=openrc
file=/tmp/openrc
type=application/zip
KV_PATH=/kv
CONSUL_PROXY_ADDR=${CONSUL_PROXY_ADDR:-http://${FED_PQDN}${KV_PATH}}  # reverse proxy
curl -o $file $CONSUL_PROXY_ADDR/v1/kv/$key?raw -H "Content-Type: $type" -H 'Expect:'
cat $file
_x

_debug "CONSUL_PROXY_ADDR: $CONSUL_PROXY_ADDR"

_debug3 "curl -sX PUT -d \"$file\" $CONSUL_PROXY_ADDR/v1/kv/$key"

#curl -4 $CONSUL_PROXY_ADDR/v1/kv/$key --upload-file $file
#curl -s -o $file $CONSUL_PROXY_ADDR/v1/kv/$key?raw -H "Content-Type: $type" -H 'Expect:'
if [[ -n "$CONSUL_CACERT_PATH" ]]; then
curl --cacert $CONSUL_CACERT_PATH --cert $CONSUL_CLIENT_CERT_PATH --key $CONSUL_CLIENT_KEY_PATH \
  -s -o $file $CONSUL_PROXY_ADDR/v1/kv/$key?raw -H "Content-Type: $type" -H 'Expect:'
else
curl \
  -s -o $file $CONSUL_PROXY_ADDR/v1/kv/$key?raw -H "Content-Type: $type" -H 'Expect:'
fi

echo $file

# return $?
}
export -f _kv_get_file

