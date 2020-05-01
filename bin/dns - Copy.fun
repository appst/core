:<<\_c
[usage]
. $PICASSO/core/bin/dns.fun

DOMAIN=bit.cafe; _dns_set test 1.2.3.4
DOMAIN=bit.cafe; _dns_get test.$DOMAIN
nslookup test.$DOMAIN

SUBDOMAIN=kv
_dns_set ${SUBDOMAIN}.bit.cafe. 10.0.0.9

DOMAIN=bit.cafe _dns_set ${SUBDOMAIN} 10.0.0.9
DOMAIN=picasso.digital _dns_get identity

DOMAIN=bit.cafe FEDERATION_DNS_KEY=$PWORK/$PID/bin/${FED_PQDN}.key _dns_set ${SUBDOMAIN} 10.0.0.9

_dns_set $VM $ip
DOMAIN=bit.cafe FEDERATION_DNS_KEY=$PWORK/$PID/bin/${FED_PQDN}.key _dns_set $VM $ip
DOMAIN=bit.cafe FEDERATION_DNS_KEY=$PWORK/$PID/bin/${FED_PQDN}.key _dns_set test 192.168.1.254

_dns_get ${SUBDOMAIN}.${DOMAIN}
_c


# ----------
:<<\_c
_dns_set <name> <ip>  # <- $DOMAIN, $FEDERATION_DNS_KEY

$1 - VM name
$2 - ip
$3 - domain
$4 - key
_c

:<<\_x
fqdn=$(echo $1 | grep -P "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$")
if [[ -n $fqdn ]]; then

else
echo "_dns_set: invalid dns name: $1"
return 1
fi

_x

:<<\_x
all dns is configured relative to $DOMAIN; however, we are dealing with two domains: bit.cafe and picasso.digital

_dns_set picasso.digital. 10.0.0.9
fqdn=picasso.digital
ip=10.0.0.9
domain=picasso.digital
key=${4:-${FEDERATION_DNS_KEY:-$DOMAIN_DNS_KEY}}
cat <<! | nsupdate -k $key
server dns
zone ${DOMAIN}.
update delete $fqdn A
update add $fqdn 3600 A $ip
send
!
_x

~~~
local ip=$2
#local domain=${3:-${DOMAIN:-${DOMAIN}}}
local domain=${3:-$DOMAIN}
#local key=${4:-${FEDERATION_DNS_KEY:-$PHOME/_/bit.cafe.key}}
#local key=${4:-${FEDERATION_DNS_KEY:-$DOMAIN_DNS_KEY}}
local key=${4:-${FEDERATION_DNS_KEY:-$PWORK/$PID/bin/${domain}.key}}
local fqdn=$1.${domain}
~~~
~~~
local DOMAIN=${DOMAIN:-$GENESIS_PQDN}
local FEDERATION_DNS_KEY=${FEDERATION_DNS_KEY:-$PWORK/$PID/bin/${FED_PQDN}.key}
local fqdn=$1.${DOMAIN}
local ip=$2

fqdn2=$(echo $fqdn | grep -P "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$")
[[ -z "$fqdn2" ]] && fqdn=$fqdn.${DOMAIN}  # fqdn=www.$DOMAIN
~~~
function _dns_set() {

~~~
local domain=${1#*.}
local subdomain=${1%%.*}
:<<\_x
_dns_set consul.picasso.digital. $MNIC_IP
_dns_get consul.picasso.digital

arg1=picasso.digital
domain=${arg1#*.}
subdomain=${arg1%%.*}
echo "domain: $domain, subdomain: $subdomain"
_x

#[[ -v _HENV_ ]] && _pdebug2 "subdomain: $subdomain, domain: $domain"
#[[ -v _GENV_ ]] && _debug2 "subdomain: $subdomain, domain: $domain"

#local domain=$(echo $1 | cut -d'.' -f1 --complement)
if [[ "$domain" != "$subdomain" ]]; then

# www.bit.cafe
local fqdn=$1
else

# www
[[ -z "$DOMAIN" ]] && { _alert 'Domain not found'; return 1; }
domain=$DOMAIN
local fqdn=$1.${DOMAIN}
fi
~~~

:<<\_s
if [[ "$1" =~ '.' ]]; then

# www.bit.cafe
local fqdn=$1
local domain=${1#*.}
#local subdomain=${1%%.*}

else
_s

# www
_debug "DOMAIN: $DOMAIN"

:<<\_x
. $PICASSO/core/bin/dns.fun
DNS_IP=192.168.1.2
FQDN=picasso.digital
SUB=
CONSUL_NODE_NAME=consul
CONSUL_DATACENTER=dc1
DOMAIN=$FQDN \
FEDERATION_DNS_KEY=/etc/bind/$FQDN.key \
_dns_set ${CONSUL_NODE_NAME}.${CONSUL_DATACENTER}${SUB} 1.2.3.4

DOMAIN=$FQDN \
FEDERATION_DNS_KEY=/etc/bind/$FQDN.key \
_dns_get ${CONSUL_NODE_NAME}.${CONSUL_DATACENTER}${SUB}
_x

[[ -z "$DOMAIN" ]] && { _alert 'Domain not found'; return 1; }

_debug "@ $@"

if [[ $1 != *. ]]; then

_debug ww252we

# $1 does not end with a period
#local fqdn=$1.${DOMAIN}
local fqdn=$1.${DOMAIN}.

else

_debug gdhg9979

# $1 does end with a period
local fqdn=$1
fi

local domain=$DOMAIN

:<<\_s
fi
_s

_debug "fqdn: $fqdn, domain: $domain"

local FEDERATION_DNS_KEY=${FEDERATION_DNS_KEY:-$PWORK/$PID/bin/${domain}.key}
local ip=$2

_debug "FEDERATION_DNS_KEY: $FEDERATION_DNS_KEY, DNS_IP: $DNS_IP, ip: $ip"

#[[ -v _HENV_ ]] && _pdebug2 "$ip $fqdn -> $domain"
#[[ -v _GENV_ ]] && _debug2 "$ip $fqdn -> $domain"
#[[ -v _HENV_ ]] && _pdebug3 "_dns_set - fqdn: $fqdn, ip: $ip, domain: $domain, key: $key"
#[[ -v _GENV_ ]] && _debug3 "_dns_set - fqdn: $fqdn, ip: $ip, domain: $domain, key: $key"

#-d - debug mode
#these two...
#server dns
#zone ${domain}.
#means dns lookups will be relative to the server dns.${domain}.

#cat <<! | BASH_ENV= sudo nsupdate -v -k $key
#cat <<! | nsupdate -v -k $key

if [[ -z "$DNS_IP" ]]; then

(( DEBUG > 0 )) && _warn "DNS_IP is not set"

cat <<! | nsupdate -k $key
update delete $fqdn A
update add $fqdn 3600 A $ip
send
!

else

#[[ -v _HENV_ ]] && _pdebug3 "cat <<! | nsupdate -k $FEDERATION_DNS_KEY
#server $DNS_IP
#update delete $fqdn A
#update add $fqdn 3600 A $ip
#send
#!
#"
#[[ -v _GENV_ ]] && _debug3 "cat <<! | nsupdate -k $FEDERATION_DNS_KEY
#server $DNS_IP
#update delete $fqdn A
#update add $fqdn 3600 A $ip
#send
#!
#"

cat <<! | nsupdate -k $FEDERATION_DNS_KEY
server $DNS_IP
update delete $fqdn A
update add $fqdn 3600 A $ip
send
!

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
zone ${domain}
update create $1 3600 A $ip
send
!
_s

:<<\_x
server dns
zone ${domain}.
_x
:<<\_x
domain=picasso.digital
key=$PWORK/$PID/bin/${domain}.key
fqdn=picasso.digital
ip=192.168.1.250
cat <<! | nsupdate -k $key
server dns
zone .
update delete $fqdn A
update add $fqdn 3600 A $ip
send
!

domain=bit.cafe
key=$PWORK/$PID/bin/${domain}.key
fqdn=test.bit.cafe
ip=192.168.1.250
cat <<! | nsupdate -k $key
server dns
zone bit.cafe.
update delete $fqdn A
update add $fqdn 3600 A $ip
send
!
nslookup $fqdn

cat <<! | nsupdate -k $key
server dns
update delete $fqdn A
update add $fqdn 3600 A $ip
send
!
nslookup $fqdn

_dns_set consul.bit.cafe. 10.0.0.9

DOMAIN=bit.cafe _dns_set consul 10.0.0.9
_x
:<<\_x
_dns_set 
nslookup test
ping test
_x

:<<\_x
#DNS_IP=$(PDEBUG=0 . $PROOT/bin/host/network/resolve.sh dns_MNIC_IP)
DNS_IP=$(. $PROOT/bin/host/network/resolve.sh dns_MNIC_IP)
ip=$DNS_IP  # use DNS ip so we get a reply
domain=$DOMAIN
#key=/etc/bind/${DOMAIN}.key
key=$(convertpath -m $PHOME/_/${DOMAIN}.key)
fqdn=test.${domain}

echo "fqdn: $fqdn, ip: $ip, domain: $domain, key: $key"

cat <<! | nsupdate -v -k $key
server $DNS_IP
zone ${domain}.
update delete $fqdn A
update add $fqdn 3600 A $ip
send
!

ping -w 1000 -n 1 $fqdn
_x
:<<\_cygwin
#DNS_IP=$(PDEBUG=0 . $PROOT/bin/host/network/resolve.sh dns_MNIC_IP)
DNS_IP=$(. $PROOT/bin/host/network/resolve.sh dns_MNIC_IP)
vm=test
ip=$DNS_IP  # use DNS ip so we get a reply
domain=$DOMAIN
key=$(convertpath -m $PHOME/_/${DOMAIN}.key)
echo "vm: $vm, ip: $ip, domain: $domain, key: $key"

cat <<! | nsupdate -v -k $key
server $DNS_IP
zone ${domain}.
update delete ${vm}.${domain} A
update add ${vm}.${domain} 3600 A $ip
send
!

ping -w 1000 -n 1 $vm.$DOMAIN
_cygwin

:<<\_s
Windows nsupdate (/mnt/c/bin/BIND9.11.2.x64/nsupdate.exe) does not support these
-r IPAddress	Specifies the IP Address of the record to update. This is used only with PTR records.
-s "CommandString"	A set of internal commands separated by spaces or colons.
-p PrimaryName
-h HostName	Specifies the name of the record to update. This is used with all records except PTR records.
-d DomainName	Specifies the name of the domain to apply the update to.
nsupdate -p dns -v -h test -d $DOMAIN -r 10.1.1.1 -k $PHOME/service/dns/${DOMAIN}.key -s d;a
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
ping $VM.$DOMAIN
_x

:<<\_s
# ----------
# test <name> <ip> [domain]
# $PHOME/_/dns.fun test dns 192.168.1.9 bit.cafe

function test() {

vm=${1:-$VM}
vm=${vm:-dummy}
ip=${2:-$IP1}
ip=${ip:-192.168.1.254}
domain=${3:-$DOMAIN}
_debug "vm: $vm, ip: $ip, domain: $domain"

DOMAIN=$domain FEDERATION_DNS_KEY=$PHOME/service/dns/${DOMAIN}.key _dns_set $vm $ip

nslookup -q=A $vm $dns || return 1  # $dns may or may not be set from $PROOT/bin/host/network/resolve.sh
[[ -n $domain ]] && { nslookup $vm.${domain} $dns || return 1; }  # $dns may or may not be set from $PROOT/bin/host/network/resolve.sh
return 0
}


# ----------
# $PHOME/_/dns.fun test

case $1 in
test) shift; test $@;;
esac
_s


function _dns_get() {

[[ (( DEBUG > 0 )) && -z "$DNS_IP" ]] && _warn "DNS_IP is not set"

#_debug "@ $@"

if [[ $1 != *. ]]; then

#_debug geyerrew

# www
[[ -z "$DOMAIN" ]] && { _alert 'Domain not found'; return 1; }

#local fqdn=$1.${DOMAIN}
local fqdn=$1.${DOMAIN}.

else

#_debug sdfsdfdsouo

# www.bit.cafe
local fqdn=$1

fi

#_debug "fqdn: $fqdn"

local r="$(nslookup $fqdn $DNS_IP)"
[[ $? -eq 0 ]] || { _alert "DNS entry not found for $1"; return 1; }

#r=$(echo "$r" | awk -F':' '/^Address: / {matched = 1} matched {print $2}' | xargs)
r=$(echo "$r" | awk -F':' '/^Address: / {matched = 1} matched {print $2}')
[[ -n $r ]] || return 1

echo $r
}
export -f _dns_get
