

# ---------- ---------- ---------- ---------- ----------
# valid ip function
valid_ip() {
    regex="\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
    echo "$1" | egrep "$regex" &>/dev/null
    return $?
}


# ---------- ---------- ---------- ---------- ----------
:<<\_c
. $PICASSO/core/bin/host.fun

_set_host_ip <name> <ip>
_set_host_ip test 1.2.3.4
_c

function _set_host_ip() {
local name=$1
local ip=$2  # MNIC_IP/XNIC_IP/

_info "_set_host_ip $name $ip"

case $ip in
MNIC_IP|XNIC_IP) ip=${!ip} ;;
esac

_debug "_set_host_ip name: $name, ip: $ip"

if grep -q "${name}$" /etc/hosts; then
# insert

sudo sed -r -i "s/^ *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+( +${name})/${ip}\1/" /etc/hosts

else
# append

sudo bash -c "cat >> /etc/hosts" <<< "$ip $name"

fi

}


# ---------- ---------- ---------- ---------- ----------
:<<\_c
usage:
_get_host_ip dns
_c
:<<\_s
#getent hosts $1 | awk '{print $1}' | head -n 1  # returns remote matches like: ntp.phub.net.cable.rogers.com
#getent ahosts $1 | sed -n 's/ *STREAM.*//p'
_s

function _get_host_ip() {
awk "{for(i=1;i<=NF;i++){ if(\$i==\"$1\"){print \$1;exit;} } }" /etc/hosts  # first occurrence only
}
export -f _get_host_ip
#awk "{for(i=1;i<=NF;i++){ if(\$i==\"$1\"){print \$1} } }" /etc/hosts  # all occurrences

:<<\_x
_get_host_ip controller
_x
:<<\_x
awk '$1  ~ /^controller/' /etc/hosts
awk '/controller/ { print $0 }' /etc/hosts
awk "/controller/ { print \$0 }" /etc/hosts
arg=controller
awk "/$arg/ { print \$0 }" /etc/hosts
awk "{ if ( match(\"^$arg$\", \$2 )) print \$1 }" /etc/hosts
_x
:<<\_x
awk '{for(i=1;i<=NF;i++){ if($i=="hostmq"){print $1} } }' /etc/hosts
awk '{for(i=1;i<=NF;i++){ if($i=="hostdb"){print $1} } }' /etc/hosts
_x


# ---------- ---------- ---------- ---------- ----------
function _inject_into_etc_hosts() {  # <OSNAME>
local OSNAME=$1
IP=IP_${OSNAME}
case ${!IP} in
MNIC_IP)
grep -q " ${OSNAME}$" /etc/hosts || sudo bash -c "cat >> /etc/hosts" <<< "$MNIC_IP ${OSNAME}"
;;
XNIC_IP)
grep -q " ${OSNAME}$" /etc/hosts || sudo bash -c "cat >> /etc/hosts" <<< "$XNIC_IP ${OSNAME}"
;;
*)
# remote...
grep -q " ${OSNAME}$" /etc/hosts || sudo bash -c "cat >> /etc/hosts" <<< "$IP ${OSNAME}"
;;
esac
}
export -f _inject_into_etc_hosts
:<<\_x
_inject_into_etc_hosts test
_x
