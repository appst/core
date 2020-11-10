:<<\_c
[usage]
. $PICASSO/core/bin/dns.fun

FED_PQDN=bit.cafe; _dns_set test 1.2.3.4
FED_PQDN=bit.cafe; _dns_get test.$FED_PQDN
nslookup test.$FED_PQDN

PHOST=kv
_dns_set ${PHOST}.bit.cafe. 10.0.0.9

FED_PQDN=bit.cafe _dns_set $PHOST 10.0.0.9
FED_PQDN=picasso.digital _dns_get identity

FED_PQDN=bit.cafe MNIC_DNS_KEY_PATH=$PID_PICASSO/${FED_PQDN}.key _dns_set $PHOST 10.0.0.9

_dns_set $PNAME $ip
FED_PQDN=bit.cafe MNIC_DNS_KEY_PATH=$PID_PICASSO/${FED_PQDN}.key _dns_set $PNAME $ip
FED_PQDN=bit.cafe MNIC_DNS_KEY_PATH=$PID_PICASSO/${FED_PQDN}.key _dns_set test 192.168.1.254

_dns_get ${PHOST}.${FED_PQDN}
_c


# ----------
:<<\_c
_dns_set <name> <ip>  # <- $FED_PQDN, $MNIC_DNS_KEY_PATH, $MNIC_NAMESERVER

$1 - <hostname>[.subdomain][FED_PQDN.]
$2 - ip
_c

#MNIC_DNS_KEY_PATH=${MNIC_DNS_KEY_PATH:-$PWORK/$PID/.picasso/${FED_PQDN}.key}
#[[ -f "$MNIC_DNS_KEY_PATH" ]] || { _alert '-f $MNIC_DNS_KEY_PATH'; return 1; }  # host only

:<<\_x
fqdn=$(echo $1 | grep -P "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$")
if [[ -n "$fqdn" ]]; then

else
echo "_dns_set: invalid dns name: $1"
return 1
fi

_x

:<<\_x
all dns is configured relative to $FED_PQDN; however, we are dealing with two domains: bit.cafe and picasso.digital

_dns_set ${HOSTNAME}.picasso.digital. 10.0.0.9
FED_PQDN=picasso.digital _dns_set $HOSTNAME 10.0.0.9

FED_PQDN=picasso.digital
FQDN=${HOSTNAME}.${FED_PQDN}
ip=10.0.0.9
key=${4:-${MNIC_DNS_KEY_PATH:-$DOMAIN_DNS_KEY_PATH}}
cat <<! | nsupdate -k $key
server dns
zone ${FED_PQDN}.
update delete ${HOSTNAME} A
update add ${HOSTNAME} 3600 A $ip
send
!
_x


:<<\_j
local FED_PQDN=${FED_PQDN:-$GENESIS_PQDN}
local MNIC_DNS_KEY_PATH=${MNIC_DNS_KEY_PATH:-$PWORK/$PID/.picasso/${FED_PQDN}.key}
local fqdn=$1.${FED_PQDN}
local ip=$2

fqdn2=$(echo $fqdn | grep -P "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$")
[[ -z "$fqdn2" ]] && fqdn=$fqdn.${FED_PQDN}  # fqdn=www.$FED_PQDN
_j
function _dns_set() {
[[ -z "$@" ]] && { echo "<FQDN> <IP>"; return 1; }

DEBUG=2
_debug2 "sdfdfgdgfs @ $@"

:<<\_j
local pqdn=${1#*.}
local subdomain=${1%%.*}
:<<\_x
_dns_set consul.picasso.digital. $MNIC_IP
_dns_get consul.picasso.digital

arg1=picasso.digital
pqdn=${arg1#*.}
subdomain=${arg1%%.*}
echo "pqdn: $pqdn, subdomain: $subdomain"
_x

#[[ -v _HENV_ ]] && _pdebug2 "subdomain: $subdomain, pqdn: $pqdn"
#[[ -v _GENV_ ]] && _debug2 "subdomain: $subdomain, pqdn: $pqdn"

#local pqdn=$(echo $1 | cut -d'.' -f1 --complement)
if [[ "$pqdn" != "$subdomain" ]]; then

# www.bit.cafe
local fqdn=$1
else

# www
[[ -z "$FED_PQDN" ]] && { _alert 'Domain not found'; return 1; }
pqdn=$FED_PQDN
local fqdn=$1.${FED_PQDN}
fi
_j

:<<\_s
if [[ "$1" =~ '.' ]]; then

# www.bit.cafe
local fqdn=$1
local pqdn=${1#*.}
#local subdomain=${1%%.*}

else
_s

# www
_debug2 "FED_PQDN: $FED_PQDN, MNIC_DNS_KEY_PATH: $MNIC_DNS_KEY_PATH"

:<<\_x
. $PICASSO/core/bin/dns.fun
MNIC_NAMESERVER=192.168.1.2
FQDN=picasso.digital
SUB=
CONSUL_NODE_NAME=consul
CONSUL_DATACENTER=dc1
MNIC_DNS_KEY_PATH=/etc/bind/$FQDN.key \
_dns_set ${CONSUL_NODE_NAME}.${CONSUL_DATACENTER}${SUB} 1.2.3.4

MNIC_DNS_KEY_PATH=/etc/bind/$FQDN.key \
_dns_get ${CONSUL_NODE_NAME}.${CONSUL_DATACENTER}${SUB}
_x


if [[ "$1" != *. ]]; then

# $1 does not end with a period
# www

[[ -z "$FED_PQDN" ]] && { _alert 'FED_PQDN not found'; return 1; }

local fqdn_dot=$1.${FED_PQDN}.

else

# $1 does end with a period
# www.bit.cafe.

local fqdn_dot=$1

fi

#local pqdn=$FED_PQDN

:<<\_s
fi
_s

_debug2 "fqdn_dot: $fqdn_dot"

#local MNIC_DNS_KEY_PATH=${MNIC_DNS_KEY_PATH:-$PWORK/$PID/.picasso/${FED_PQDN}.key}
local ip=$2

_debug2 "MNIC_DNS_KEY_PATH: $MNIC_DNS_KEY_PATH, MNIC_NAMESERVER: $MNIC_NAMESERVER, ip: $ip"

#-d - debug mode
#these two...
#server dns
#zone ${MEMBER_PQDN}.
#means dns lookups will be relative to the server dns.${MEMBER_PQDN}.

#cat <<! | BASH_ENV= sudo nsupdate -v -k $key
#cat <<! | nsupdate -v -k $key

if [[ -z "$MNIC_NAMESERVER" ]]; then

(( DEBUG > 0 )) && _warn "MNIC_NAMESERVER is not set"

_debug2 "fqdn_dot: $fqdn_dot, key: $key"

cat <<! | nsupdate -k $key
update delete $fqdn_dot A
update add $fqdn_dot 3600 A $ip
send
!

else

#[[ -v _HENV_ ]] && _pdebug3 "cat <<! | nsupdate -k $MNIC_DNS_KEY_PATH
#server $MNIC_NAMESERVER
#update delete $fqdn_dot A
#update add $fqdn_dot 3600 A $ip
#send
#!
#"
#[[ -v _GENV_ ]] && _debug3 "cat <<! | nsupdate -k $MNIC_DNS_KEY_PATH
#server $MNIC_NAMESERVER
#update delete $fqdn_dot A
#update add $fqdn_dot 3600 A $ip
#send
#!
#"

_debug "fqdn_dot: $fqdn_dot, MNIC_DNS_KEY_PATH: $MNIC_DNS_KEY_PATH"
_debug "MNIC_DNS_KEY: $MNIC_DNS_KEY"

if [[ -n "$MNIC_DNS_KEY" ]]; then

_debug dgdgdfg

cat <<! | nsupdate -k <(echo $MNIC_DNS_KEY)
server $MNIC_NAMESERVER
update delete $fqdn_dot A
update add $fqdn_dot 3600 A $ip
send
!

else

_debug rtywww

local MNIC_DNS_KEY_PATH=${MNIC_DNS_KEY_PATH:-$PWORK/$PID/.picasso/${FED_PQDN}.key}

cat <<! | nsupdate -k $MNIC_DNS_KEY_PATH
server $MNIC_NAMESERVER
update delete $fqdn_dot A
update add $fqdn_dot 3600 A $ip
send
!

fi

fi

#[[ -v _HENV_ ]] && _pdebug3 "_dns_set - nsupdate \$?: $?"
#[[ -v _GENV_ ]] && _debug3 "_dns_set - nsupdate \$?: $?"

#case $PSHELL in
#cygwin|msys)
#1>/dev/null ipconfig /flushdns  # HACK for Windows
#;;
#esac

}
export -f _dns_set


:<<\_s
cat <<! | sudo nsupdate -v -k $key
server dns
zone ${FED_PQDN}
update create $1 3600 A $ip
send
!
_s

:<<\_x
server dns
zone ${FED_PQDN}.
_x
:<<\_x
FED_PQDN=picasso.digital
key=$PID_PICASSO/${FED_PQDN}.key
fqdn=picasso.digital
ip=192.168.1.250
cat <<! | nsupdate -k $key
server dns
zone .
update delete $fqdn_dot A
update add $fqdn_dot 3600 A $ip
send
!

FED_PQDN=bit.cafe
key=$PID_PICASSO/${FED_PQDN}.key
fqdn=test.bit.cafe
ip=192.168.1.250
cat <<! | nsupdate -k $key
server dns
zone bit.cafe.
update delete $fqdn_dot A
update add $fqdn_dot 3600 A $ip
send
!
nslookup $fqdn

cat <<! | nsupdate -k $key
server dns
update delete $fqdn_dot A
update add $fqdn_dot 3600 A $ip
send
!
nslookup $fqdn

_dns_set consul.bit.cafe. 10.0.0.9

FED_PQDN=bit.cafe _dns_set consul 10.0.0.9
_x
:<<\_x
_dns_set 
nslookup test
ping test
_x

:<<\_x
#MNIC_NAMESERVER=$(PDEBUG=0 . $PROOT/bin/host/network/resolve.sh MNIC_NAMESERVER)
MNIC_NAMESERVER=$(. $PROOT/bin/host/network/resolve.sh MNIC_NAMESERVER)
ip=$MNIC_NAMESERVER  # use DNS ip so we get a reply
#key=/etc/bind/${FED_PQDN}.key
key=$(convertpath -m $PHOME/_/${FED_PQDN}.key)
fqdn=test.${FED_PQDN}

echo "fqdn: $fqdn, ip: $ip, FED_PQDN: $FED_PQDN, key: $key"

cat <<! | nsupdate -v -k $key
server $MNIC_NAMESERVER
zone ${FED_PQDN}.
update delete $fqdn_dot A
update add $fqdn_dot 3600 A $ip
send
!

ping -w 1000 -n 1 $fqdn
_x
:<<\__cygwin
#MNIC_NAMESERVER=$(PDEBUG=0 . $PROOT/bin/host/network/resolve.sh MNIC_NAMESERVER)
MNIC_NAMESERVER=$(. $PROOT/bin/host/network/resolve.sh MNIC_NAMESERVER)
PNAME=test
ip=$MNIC_NAMESERVER  # use DNS ip so we get a reply
FED_PQDN=$FED_PQDN
key=$(convertpath -m $PHOME/_/${FED_PQDN}.key)
echo "PNAME: $PNAME, ip: $ip, FED_PQDN: $FED_PQDN, key: $key"

cat <<! | nsupdate -v -k $key
server $MNIC_NAMESERVER
zone ${FED_PQDN}.
update delete ${PNAME}.${FED_PQDN} A
update add ${PNAME}.${FED_PQDN} 3600 A $ip
send
!

ping -w 1000 -n 1 $PNAME.$FED_PQDN
__cygwin

:<<\_s
Windows nsupdate (/mnt/c/bin/BIND9.11.2.x64/nsupdate.exe) does not support these
-r IPAddress	Specifies the IP Address of the record to update. This is used only with PTR records.
-s "CommandString"	A set of internal commands separated by spaces or colons.
-p PrimaryName
-h HostName	Specifies the name of the record to update. This is used with all records except PTR records.
-d DomainName	Specifies the name of the domain to apply the update to.
nsupdate -p dns -v -h test -d $FQDN -r 10.1.1.1 -k $PHOME/service/dns/${FED_PQDN}.key -s d;a
_s

:<<\_x
cat <<! | nsupdate -v -k $PHOME/service/dns/bit.cafe.key
server dns
zone bit.cafe
update delete test.bit.cafe. A
update add test.bit.cafe. 3600 A 10.1.1.1
show
send
!
ipconfig /flushdns  # HACK for Windows
ping -n 2 test.bit.cafe
_x
:<<\_x
. $PHOME/yoga.sh && _dns_set test 10.1.1.1
sleep 60
getent hosts test.bit.cafe | awk '{ print $1 }'
dig @192.168.1.5 +short test.bit.cafe
dig +short test.bit.cafe
_x
:<<\_x
# Windows requires flushing of dns if the name is already cached
ipconfig /flushdns
ping $PNAME.$FED_PQDN
_x

:<<\__s
# ----------
# test <name> <ip> [pqdn]
# $PHOME/_/dns.fun test dns 192.168.1.9 bit.cafe

function test() {

PNAME=${1:-$PNAME}
PNAME=${PNAME:-dummy}
ip=${2:-$IP1}
ip=${ip:-192.168.1.254}
pqdn=${3:-$FED_PQDN}
_debug "PNAME: $PNAME, ip: $ip, pqdn: $pqdn"

pqdn=$FED_PQDN MNIC_DNS_KEY_PATH=$PHOME/service/dns/${pqdn}.key _dns_set $PNAME $ip

nslookup -q=A $PNAME $dns || return 1  # $dns may or may not be set from $PROOT/bin/host/network/resolve.sh
[[ -n "$pqdn" ]] && { nslookup $PNAME.${pqdn} $dns || return 1; }  # $dns may or may not be set from $PROOT/bin/host/network/resolve.sh
return 0
}


# ----------
# $PHOME/_/dns.fun test

case $1 in
test) shift; test $@;;
esac
__s

:<<\_j
function _dns_get() {

(( DEBUG > 0 )) && [[ -z "$MNIC_NAMESERVER" ]] && _warn "MNIC_NAMESERVER is not set"

#_debug "@ $@"


# ----------
:<<\_s
if [[ "$1" != *. ]]; then

# www

[[ -z "$FED_PQDN" ]] && { _alert '-z "$FED_PQDN"'; return 1; }

local fqdn_dot=$1.${FED_PQDN}.

else

# www.bit.cafe.

local fqdn_dot=$1

fi

_debug "fqdn_dot: $fqdn_dot"

local r="$(nslookup $fqdn_dot $MNIC_NAMESERVER)"
_s


# ----------
fqdn=$1
local r="$(nslookup $fqdn $MNIC_NAMESERVER)"

[[ $? -eq 0 ]] || { _alert "DNS entry not found for $1"; return 1; }

#r=$(echo "$r" | awk -F':' '/^Address: / {matched = 1} matched {print $2}' | xargs)
r=$(echo "$r" | awk -F':' '/^Address: / {matched = 1} matched {print $2}')
[[ -n "$r" ]] || return 1

echo $r
}
_j



function _dns_get() {
[[ -z "$@" ]] && { echo "<FQDN>"; return 1; }

(( DEBUG > 0 )) && [[ -z "$MNIC_NAMESERVER" ]] && _warn "MNIC_NAMESERVER is not set"

#_debug "@ $@"

fqdn=$1
local r="$(nslookup $fqdn $MNIC_NAMESERVER)"

[[ $? -eq 0 ]] || { _alert "DNS entry not found for $1"; return 1; }

#r=$(echo "$r" | awk -F':' '/^Address: / {matched = 1} matched {print $2}' | xargs)
r=$(echo "$r" | awk -F':' '/^Address: / {matched = 1} matched {print $2}')
[[ -n "$r" ]] || return 1

echo $r
}
export -f _dns_get
