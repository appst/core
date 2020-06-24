#!/usr/bin/env bash
:<<\_c
iptables/iptables.sh

https://gist.github.com/thomasfr/9712418
http://ubuntuforums.org/archive/index.php/t-1276011.html
https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
_c


#DEBUG=1
_debug_firewall 9sf7s9fs9fds9f
:<<\_c
# see port changes
service smb stop
netstat -ln > netstat-ln-smb.before
service smb start
netstat -ln > netstat-ln-smb.after
diff netstat-ln-smb.*
_c

:<<\_c
when this script first executes we have network access properly functioning from vagrant
this script then purges vagrant's configuration (ssh and samba) and immediately replaces it

iptable chains are ORDERED lists where the first matching rule is run
rules may be inserted (with offset) or appended
inserting rules brings with it the issue of messing up the order - ie: you always want the most frequently utilized rule first in the list
appending rules brings with it the issue of appending a rule after another rule that terminates the chain - ie: after 'iptables -A INPUT -j DROP'
we can get around these issues by creating user-defined chains that are embedded within the default chain
rules are then appended to these user-defined chains
user-defined chains maintain the order of the default chain
this script creates a default chain that does the following...
1) primary rules
2) calls user-defined chains
3) logging rules
4) accepts or rejects all traffic depending on policy

user-defined chains:
TCP_IN
UDP_IN
TCP_OUT
UDP_OUT

the user-defined chains may then be flushed and appended to for testing

iptables-input-accept-forward-accept-output-accept...
sudo bash -c "iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X; iptables -t mangle -F; iptables -t mangle -X; iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT"

iptables-input-drop-forward-drop-output-accept...
sudo bash -c "iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X; iptables -t mangle -F; iptables -t mangle -X; iptables -P INPUT DROP; iptables -P FORWARD DROP; iptables -P OUTPUT ACCEPT"

iptables-input-drop-forward-drop-output-accept +ssh...
sudo bash -c "iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X; iptables -t mangle -F; iptables -t mangle -X; iptables -P INPUT DROP; iptables -P FORWARD DROP; iptables -P OUTPUT ACCEPT; \
 iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -m comment --comment "ssh-server" -j ACCEPT; \
 iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -m comment --comment "ssh-server" -j ACCEPT; \
"


sudo iptables -L

sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

iptables -N TCP_IN
iptables -N TCP_OUT
iptables -N UDP_IN
iptables -N UDP_OUT
iptables -A TCP_IN -j ACCEPT
iptables -A TCP_OUT -j ACCEPT
iptables -A UDP_IN -j ACCEPT
iptables -A UDP_OUT -j ACCEPT

sudo iptables -I TCP_IN -j ACCEPT
sudo iptables -I TCP_OUT -j ACCEPT
sudo iptables -I UDP_IN -j ACCEPT
sudo iptables -I UDP_OUT -j ACCEPT

sudo journalctl -f | grep 'TCP_IN\|TCP_OUT'

sudo iptables -D TCP_IN -j ACCEPT
sudo iptables -D TCP_OUT -j ACCEPT

drop policy...
iptables -F TCP_IN
iptables -F TCP_OUT
iptables -F UDP_IN
iptables -F UDP_OUT
iptables -A TCP_IN -j DROP
iptables -A TCP_OUT -j DROP
iptables -A UDP_IN -j DROP
iptables -A UDP_OUT -j DROP

ACCEPT(ing) or DROP(ing) a packet terminates its rule matching
packets traverse the chains until they are either ACCEPT(ed) or DROP(ed) or the end of the chains is reached

1) to find PC's running windows 8 and windows 7: UDP 3702, UDP 5355, TCP 5357, TCP 5358.
2) to find PC's running earlier version of windows: UDP 137, UDP 138:, TCP 139 - NetBIOS over TCP/IP aka NetBT aka netbios-ssn - (Windows NT)
, TCP 445 - SMB/CIFS over IP (Windows 2000+)
, UDP 5355.
3) to find other network devices I enabled: UDP 1900, TCP 2869, UDP 3702, UDP 5355, TCP 5357, TCP 5358.

usage:

. $PICASSO/core/bin/iptables.sh
_iptables-input-drop-forward-drop-output-drop
iptables -F TCP_IN
iptables -F TCP_OUT
#_iptables "-A TCP_IN -p tcp -i $MNIC_ -s 192.168.1.0/24 --dport 445 -m conntrack --ctstate NEW -j ACCEPT"
_iptables "-A TCP_IN -p tcp -s 192.168.1.0/24 --dport 445 -m conntrack --ctstate NEW -j ACCEPT"
ls $PICASSO/install
iptables-save > /etc/sysconfig/iptables  # iptables will be restored at restart

NEW - The connection has not yet been seen.
RELATED - The connection is new, but is related to another connection already permitted.
ESTABLISHED - The connection is already established.
INVALID - The traffic couldn't be identified for some reason.

REJECT target will send a reply icmp packet to the source system telling that system that the packet has been rejected. By default the message will be "port is unreachable".
REJECT target is vulnerable to DoS style attacks
DROP target simply drops the packet without sending any reply packets back.

http://crm.vpscheap.net/knowledgebase.php?action=displayarticle&id=29
_c


#[[ -n "$LAN" ]] && nic=nic$LAN && NIC=${!nic}

_debug_firewall
IPT="/sbin/iptables"

# Your DNS servers you use: cat /etc/resolv.conf
#DNS_SERVER="192.168.1.100 8.8.8.8"
PACKAGE_SERVER="0.0.0.0/0"  # "ftp.us.debian.org security.debian.org"
_alert "PACKAGE_SERVER: $PACKAGE_SERVER"

~~~
if (( DEBUG > 0 )); then
alias _tcp_input_accept='/sbin/iptables -A INPUT -p tcp -j ACCEPT -m comment --comment "$_TOP_:$LINENO" '
alias _tcp_output_accept='/sbin/iptables -A OUTPUT -p tcp -j ACCEPT -m comment --comment "$_TOP_:$LINENO" '
alias _udp_input_accept='/sbin/iptables -A INPUT -p udp -j ACCEPT -m comment --comment "$_TOP_:$LINENO" '
alias _udp_output_accept='/sbin/iptables -A OUTPUT -p udp -j ACCEPT -m comment --comment "$_TOP_:$LINENO" '
else
~~~
#alias _tcp_input_accept='/sbin/iptables -A INPUT -p tcp -j ACCEPT '
#alias _tcp_output_accept='/sbin/iptables -A OUTPUT -p tcp -j ACCEPT '
#alias _udp_input_accept='/sbin/iptables -A INPUT -p udp -j ACCEPT '
#alias _udp_output_accept='/sbin/iptables -A OUTPUT -p udp -j ACCEPT '

. $PICASSO/core/bin/iptables.fun
~~~
fi
~~~

# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _iptables_provision() {
#_fin ":${FUNCNAME}"

case $OS in

redhat|fedora)

_install iptables-services

# disable firewalld
#systemctl is-active -q firewalld.service && systemctl stop firewalld.service
systemctl disable firewalld.service --now &> /dev/null
systemctl mask firewalld.service &> /dev/null

# Create this or starting iptables will fail
touch /etc/sysconfig/iptables

# enable iptables
systemctl unmask iptables.service
systemctl unmask ip6tables.service
systemctl start iptables.service
systemctl start ip6tables.service
systemctl enable iptables.service
systemctl enable ip6tables.service

:<<\_x
systemctl is-active iptables.service
systemctl status iptables.service
systemctl stop iptables.service

systemctl status firewalld.service
_x
;;

debian|ubuntu)

# iptables is a kernel module and not a service in ubuntu!
# to create a service for it see: http://serverfault.com/questions/129086/how-to-start-stop-iptables-on-ubuntu

_debug_firewall s9fs9fs9

_install iptables-persistent 2>/dev/null

_debug_firewall df4oisfkshf
mkdir -p /etc/iptables
#chmod go-rwx /etc/iptables

:<<\_x
systemctl is-active ufw.service
systemctl status ufw.service
systemctl stop ufw.service
_x
;;

*)
_alert "TODO: $OS"
exit 1
;;

esac

#_fout ":${FUNCNAME}"
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _build_default_chain() {
#_fin ":${FUNCNAME}"

[[ -n $MNIC_ ]] && {
trusted_nic=$MNIC_
trusted_network=$MNIC_NETWORK/$MNIC_PREFIX
}

# Allow Established Sessions
_tcp_input_accept -m conntrack --ctstate ESTABLISHED,RELATED
_tcp_output_accept -m conntrack --ctstate ESTABLISHED

_udp_input_accept -m conntrack --ctstate ESTABLISHED,RELATED
#_udp_output_accept -m conntrack --ctstate ESTABLISHED,RELATED
_udp_output_accept -m conntrack --ctstate ESTABLISHED

# echo "allow all and everything on localhost"
#$IPT -A INPUT -i lo -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
#$IPT -A OUTPUT -o lo -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT  # https://unix.stackexchange.com/questions/395328/iptables-rule-for-loopback
$IPT -A OUTPUT -o lo -j ACCEPT

$IPT -A INPUT -m conntrack --ctstate INVALID -j DROP

# ----------
## This should be one of the first rules so dns lookups are already allowed for your other rules
# http://www.cyberciti.biz/tips/linux-iptables-12-how-to-block-or-open-dnsbind-service-port-53.html
:<<\_x
cat <<EOF >> /etc/resolv.conf
nameserver 8.8.8.8
EOF

for ip in $(</etc/resolv.conf | grep nameserver | awk '{print $2}')
do
echo "nameserver: $ip"
done
_x
:<<\_x
cat /etc/resolv.conf
_x

#for ip in $DNS_SERVER

for ip in $(</etc/resolv.conf | grep "^nameserver" | awk '{print $2}')
do

#iptables -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
#iptables -A OUTPUT -p udp --sport 53 -m conntrack --ctstate NEW -m comment --comment "$_TOP_:$LINENO" -j ACCEPT

#iptables -A OUTPUT -p udp --sport 1024:65535 -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A INPUT -p udp -s $ip --sport 53 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -p tcp --sport 1024:65535 -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A INPUT -p tcp -s $ip --sport 53 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT

_debug_firewall "Allowing outgoing (client) DNS lookups (tcp, udp port 53) to server '$ip'"
#	$IPT -A OUTPUT -p udp -d $ip --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "$_TOP_:$LINENO"
#	$IPT -A INPUT  -p udp -s $ip --sport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "$_TOP_:$LINENO"
#$IPT -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "$_TOP_:$LINENO"
#$IPT -A INPUT  -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT -m comment --comment "$_TOP_:$LINENO"

:<<\_c
http://www.cyberciti.biz/tips/linux-iptables-12-how-to-block-or-open-dnsbind-service-port-53.html
SERVER_IP="202.54.10.20"
DNS_SERVER="202.54.1.5 202.54.1.6"
for ip in $DNS_SERVER
do
iptables -A OUTPUT -p udp -s $SERVER_IP --sport 1024:65535 -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -s $ip --sport 53 -d $SERVER_IP --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT-p tcp -s $SERVER_IP --sport 1024:65535 -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s $ip --sport 53 -d $SERVER_IP --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
done
_c
SERVER_IP=$ip
#SERVER_IP=0/0
_udp_output_accept --sport 1024:65535 -d $ip --dport 53 -m state --state NEW,ESTABLISHED
_udp_input_accept -s $ip --sport 53 --dport 1024:65535 -m state --state ESTABLISHED
_tcp_output_accept --sport 1024:65535 -d $ip --dport 53 -m state --state NEW,ESTABLISHED  # apparently Google requires this?
_tcp_input_accept -s $ip --sport 53 --dport 1024:65535 -m state --state ESTABLISHED  # apparently Google requires this?


# not sure if tcp is necessary
#	$IPT -A OUTPUT -p tcp --sport 1024:65535 -d $ip --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "$_TOP_:$LINENO"
#	$IPT -A INPUT  -p tcp -s $ip --sport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "$_TOP_:$LINENO"
#_tcp_out_accept --dport 53 -m conntrack --ctstate NEW
#_udp_out_accept --dport 53 -m conntrack --ctstate NEW

#$IPT -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
#$IPT -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT

#	$IPT -A OUTPUT -p udp -d $ip --dport 53 -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
#	$IPT -A INPUT  -p udp -s $ip --sport 53 -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
#	$IPT -A OUTPUT -p tcp -d $ip --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
#	$IPT -A INPUT  -p tcp -s $ip --sport 53 -m conntrack --ctstate ESTABLISHED     -j ACCEPT
done

:<<\_s
SERVER_IP=0/0
_udp_output_accept -s $SERVER_IP --sport 1024:65535 --dport 53 -m state --state NEW,ESTABLISHED
_udp_input_accept --sport 53 -d $SERVER_IP --dport 1024:65535 -m state --state ESTABLISHED
_tcp_output_accept -s $SERVER_IP --sport 1024:65535 --dport 53 -m state --state NEW,ESTABLISHED
_tcp_input_accept --sport 53 -d $SERVER_IP --dport 1024:65535 -m state --state ESTABLISHED
_s

:<<\_s
# establish a TCP chain and a UDP chain that we add all further rules to
# separate tables permit us to append rules to them while having order maintained within the default table
# iow: we don't run into the problem of appending a rule after a rule that rejects its traffic
$IPT -N TCP_IN
$IPT -N UDP_IN
$IPT -N TCP_OUT
$IPT -N UDP_OUT

$IPT -A INPUT -p udp -j UDP_IN -m comment --comment "$_TOP_:$LINENO"
$IPT -A INPUT -p tcp -j TCP_IN -m comment --comment "$_TOP_:$LINENO"
$IPT -A OUTPUT -p udp -j UDP_OUT -m comment --comment "$_TOP_:$LINENO"
$IPT -A OUTPUT -p tcp -j TCP_OUT -m comment --comment "$_TOP_:$LINENO"
_s

# ----------
:<<\_s
# Allow Ping from Outside(LAN) to Inside
#$IPT -A INPUT -s 192.168.1.0/24 -p icmp --icmp-type echo-request -j ACCEPT
#$IPT -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
#$IPT -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 0 -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 3 -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 11 -m comment --comment "$_TOP_:$LINENO" -j ACCEPT

# echo "Allow outgoing icmp connections (pings,...)"
#$IPT -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
$IPT -A OUTPUT -p icmp -m conntrack --ctstate NEW,ESTABLISHED,RELATED -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
$IPT -A INPUT  -p icmp -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
#$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

## Enable or allow incoming ICMP ping requests
#$IPT -A INPUT -p icmp --icmp-type 8 -s 0/0 -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#$IPT -A OUTPUT -p icmp --icmp-type 0 -s 0/0 -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT
## Allow or enable outgoing ping requests
#$IPT -A OUTPUT -p icmp --icmp-type 8 -s $IP -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#$IPT -A INPUT -p icmp --icmp-type 0 -s 0/0 -d $IP -m state --state ESTABLISHED,RELATED -j ACCEPT

# we will permit ping, but rate-limit type 8 to prevent DoS-attack
$IPT -A INPUT -p icmp --icmp-type 8 -m limit --limit 1/second -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
_s

# echo "Allow incoming icmp connections (pings,...)"
#$IPT -A INPUT -p icmp --icmp-type 8 -s 0/0 -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#$IPT -A OUTPUT -p icmp --icmp-type 0 -s 0/0 -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT
#$IPT -A OUTPUT -p icmp -j ACCEPT
#$IPT -A INPUT -p icmp -j ACCEPT

# echo-reply     :  0
# destination-unreachable : 3
# redirect        : 5
# echo-request   :  8
# time-exceeded  : 11
:<<\_x
iptables -p icmp -h  # list ping types
_x

# Allow Ping from Outside to Inside
#$IPT -A OUTPUT -p icmp --icmp-type echo-request -s 0/0 -m limit --limit 10/s -j ACCEPT -m comment --comment "echo-request"
#$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

$IPT -A INPUT -p icmp --icmp-type echo-request -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -m limit --limit 10/s -j ACCEPT -m comment --comment "echo-request"
$IPT -A OUTPUT -p icmp --icmp-type echo-reply -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT

#iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -d $MNIC_IP -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A OUTPUT -p icmp --icmp-type 0 -s $MNIC_IP -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A OUTPUT -p icmp --icmp-type 0 -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT

#iptables -A INPUT -p icmp --icmp-type destination-unreachable -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


# Allow Ping from Inside to Outside
#$IPT -A INPUT -p icmp --icmp-type echo-request -j ACCEPT -m state --state NEW,ESTABLISHED,RELATED -m comment --comment "echo-request"
#$IPT -A OUTPUT -p icmp --icmp-type echo-reply -d 0/0 -m state --state ESTABLISHED,RELATED -m limit --limit 10/s -j ACCEPT -m comment --comment "echo-reply"

$IPT -A OUTPUT -p icmp --icmp-type echo-request -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT -m comment --comment "echo-request"
$IPT -A INPUT -p icmp --icmp-type echo-reply -s 0/0 -m state --state ESTABLISHED,RELATED -m limit --limit 10/s -j ACCEPT -m comment --comment "echo-reply"

$IPT -A INPUT -p icmp --icmp-type destination-unreachable -d 0/0 -m limit --limit 10/s -j ACCEPT -m comment --comment "destination-unreachable"
$IPT -A INPUT -p icmp --icmp-type redirect -d 0/0 -m limit --limit 10/s -j ACCEPT -m comment --comment "redirect"
$IPT -A INPUT -p icmp --icmp-type time-exceeded -s 0/0 -j ACCEPT -m comment --comment "time-exceeded"

:<<\_s
# ICMP
# We accept icmp in if it is "related" to other connections (e.g a time exceeded (11)
# from a traceroute) or it is part of an "established" connection (e.g. an echo reply (0)
# from an echo-request (8)).
$IPT -A INPUT -p icmp -i $IFACE -m state --state ESTABLISHED,RELATED -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
# We always allow icmp out.
$IPT -A OUTPUT -p icmp -o $IFACE -m state --state NEW,ESTABLISHED,RELATED -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
_s

## TRACEROUTE
# Outgoing traceroute anywhere.
# The reply to a traceroute is an icmp time-exceeded which is dealt with by the next rule.
#iptables -A OUTPUT -p udp -o $IFACE -m state --state NEW -m comment --comment "$_TOP_:$LINENO" -j ACCEPT

:<<\_s
$IPT -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
$IPT -A INPUT -p tcp -j REJECT --reject-with tcp-rst

$IPT -A INPUT -j REJECT --reject-with icmp-cat-unreachable
_s
:<<\_x
sudo tcpdump -i any -n -v 'icmp[icmptype] = icmp-echoreply or icmp[icmptype] = icmp-echo'
_x


# ----------
:<<\_c
# DHCP client
# http://www.linklogger.com/UDP67_68.htm
client request: UDP 0.0.0.0:68 -> 255.255.255.255:67
server reply: UDP 192.168.1.101:67 -> 255.255.255.255:68
client renewal request: UDP 192.168.1.101:67 -> 192.168.1.1:68
server renewal reply: UDP 192.168.1.1:68 -> 192.168.1.101:67
_c

_debug_firewall sf0s033ljfs0

if [[ -n "$IFACE" ]]; then

_debug_firewall "IFACE: $IFACE"

# SSH - from a remote client into the vm via vagrant
# Allow incoming SSH connection from vagrant(10.0.2.2) -> $IFACE(tcp/22)
_tcp_input_accept -i $IFACE --dport 22 -s 10.0.2.2 -m conntrack --ctstate NEW,ESTABLISHED -m comment --comment "vagrant-ssh-server"
_tcp_output_accept -o $IFACE --sport 22 -d 10.0.2.2 -m conntrack --ctstate ESTABLISHED -m comment --comment "vagrant-ssh-server"

#$IPT -A INPUT -i $IFACE -p tcp -s $GW -m multiport --dports 67,68 -m comment --comment "$_TOP_:$LINENO" -j ACCEPT
#$IPT -A INPUT -i $IFACE -p udp -s $GW -m multiport --dports 67,68 -m comment --comment "$_TOP_:$LINENO" -j ACCEPT

#_tcp_input_accept -i $IFACE -s 10.0.2.15 -m multiport --dports 67,68  # vagrant
#_tcp_output_accept -o $IFACE -d 10.0.2.15 -m multiport --dports 67,68  # vagrant

# DHCP client
_udp_output_accept -o $IFACE -d 10.0.2.2 -m multiport --dports 67,68 -m comment --comment "vagrant-dhcp-client"
_udp_input_accept -i $IFACE -s 10.0.2.2 -m multiport --sports 67,68 -m comment --comment "vagrant-dhcp-client"
fi

_debug_firewall 935739urowfw

if [[ -n "$trusted_nic" ]]; then

_debug_firewall "trusted_nic: $trusted_nic, GW: $GW"

# SSH in from LAN(192.168.1.0/24) -> $trusted_nic(tcp/22)
#_tcp_input_accept --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -m comment --comment "ssh"
#_tcp_output_accept --sport 22 -m conntrack --ctstate ESTABLISHED -m comment --comment "ssh"
_tcp_input_accept -i $trusted_nic -s $trusted_network --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -m comment --comment "ssh-server"
_tcp_output_accept -o $trusted_nic -d $trusted_network --sport 22 -m conntrack --ctstate ESTABLISHED -m comment --comment "ssh-server"

:<<\_s
# SSH out to $trusted_nic/$trusted_network(tcp/22)
# Allow outgoing SSH connection: $trusted_nic(tcp/22) <-> LAN(192.168.1.0/24)
_tcp_output_accept -o $trusted_nic -d $trusted_network --dport 22 -m conntrack --ctstate NEW,ESTABLISHED
_tcp_input_accept -i $trusted_nic -s $trusted_network --sport 22 -m conntrack --ctstate ESTABLISHED
_s

# DHCP/BOOTP client
# i'm not sure this is necessary
#_udp_output_accept -o $trusted_nic -d $GW -m multiport --dports 67,68 -m comment --comment "dhcp-client"
#_udp_input_accept -i $trusted_nic -s $GW -m multiport --sports 67,68 -m comment --comment "dhcp-client"
#_tcp_output_accept -o $trusted_nic -d $GW -m multiport --dports 67,68 -m comment --comment "dhcp-client"
#_tcp_input_accept -i $trusted_nic -s $GW -m multiport --sports 67,68 -m comment --comment "dhcp-client"
_udp_output_accept -o $trusted_nic -m multiport --dports 67,68 -m comment --comment "dhcp-client"
_udp_input_accept -i $trusted_nic -m multiport --sports 67,68 -m comment --comment "dhcp-client"
_tcp_output_accept -o $trusted_nic -m multiport --dports 67,68 -m comment --comment "dhcp-client"
_tcp_input_accept -i $trusted_nic -m multiport --sports 67,68 -m comment --comment "dhcp-client"
fi

_debug_firewall jsfs57s6f9sfiwh

# ----------
for ip in $PACKAGE_SERVER
do
_debug_firewall "Allow outgoing connection to '$ip' for ftp, http, https"
#_tcp_output_accept -d $ip -m multiport --dports 20,21 -m conntrack --ctstate NEW,ESTABLISHED
#_tcp_input_accept -s $ip -m multiport --sports 20,21 -m conntrack --ctstate ESTABLISHED
_tcp_output_accept -d $ip -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -m comment --comment "http/https-client"
_tcp_input_accept -s $ip -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -m comment --comment "http/https-client"
done

_debug_firewall f93274wfos0fsd

# ----------
# NTP client
_udp_output_accept --dport 123 -m conntrack --ctstate NEW,ESTABLISHED -m comment --comment "ntp-client"
_udp_input_accept --sport 123 -m conntrack --ctstate ESTABLISHED -m comment --comment "ntp-client"
#_open_client_firewall FNICSA 123 ntp UDP  # uses TCP_IN chain


# ----------
# ignore Pre-Windows 2000 systems NetBIOS over TCP/IP (ports 137,138,139)
_udp_input_drop -m multiport --dports 137:138,515 -m comment --comment "netbios"
#_tcp_input_drop -m multiport --dports 139,445,515 -m comment --comment "netbios"
_udp_output_drop -m multiport --sports 137:138,515 -m comment --comment "netbios"
#_tcp_output_drop -m multiport --sports 139,445,515 -m comment --comment "netbios"

# ignore syncthing
_udp_input_drop --dport 21027 -m comment --comment "syncthing"
_tcp_input_drop --dport 22000 -m comment --comment "syncthing"

$TEST && {
# the network may not be operative
#ping google.com -c1 1>/dev/null  # test ICMP and DNS
} #$TEST

:<<\_c
establish a TCP chain and a UDP chain that we add all further rules to...

standard filtering rules have all been applied
we now add custom tables where we direct all packets that fall through the standard rules
our additional rules should be added to these tables
that way we can purge the tables without affecting the standard rules
and we can attach logging that does not output the standard rules

# separate tables permit us to append rules to them while having order maintained within the default table
# iow: we don't run into the problem of appending a rule after a rule that rejects its traffic
_c
$IPT -N TCP_IN
$IPT -N UDP_IN
$IPT -N TCP_OUT
$IPT -N UDP_OUT

$IPT -A INPUT -p udp -j UDP_IN
$IPT -A INPUT -p tcp -j TCP_IN
$IPT -A OUTPUT -p udp -j UDP_OUT
$IPT -A OUTPUT -p tcp -j TCP_OUT

#$IPT -A INPUT -m conntrack --ctstate INVALID -j DROP

:<<\_x
sudo iptables -L TCP_IN
_x
#_fout ":${FUNCNAME}"
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _iptables-input-accept-forward-accept-output-accept() {
#_fin ":${FUNCNAME}"

_debug_firewall "_iptables-input-accept-forward-accept-output-accept"

# i let everything through here - bad
#IPT="/sbin/iptables"
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT  # Allow Internal Network to External network
$IPT -P OUTPUT ACCEPT

_debug_firewall sf9s9sd9fsf
_build_default_chain

_debug_firewall sfshjlsdf

[[ $DEBUG -gt 1 ]] && {
# log what falls through
/sbin/iptables -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT INPUT ACCEPT: '
/sbin/iptables -A FORWARD -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT FORWARD ACCEPT: '
/sbin/iptables -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT OUTPUT ACCEPT: '
}

#_fout ":${FUNCNAME}"
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _iptables-input-drop-forward-drop-output-accept() {
#_fin

_debug_firewall "_iptables-input-drop-forward-drop-output-accept"

$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT

_build_default_chain

[[ $DEBUG -gt 1 ]] && {
# log what falls through
/sbin/iptables -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT INPUT DROP: '
/sbin/iptables -A FORWARD -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT FORWARD DROP: '
/sbin/iptables -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT OUTPUT ACCEPT: '
}

:<<\_s
# Log before dropping
$IPT -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IP INPUT drop: '
#$IPT -A INPUT  -j DROP
 
#$IPT -A OUTPUT -j ACCEPT
_s

# i'm not sure what this is...
#sudo iptables -D INPUT -m conntrack --ctstate INVALID -j DROP

:<<\_s
# these are redundant with their policy already set to drop
# also, they may cause problems
# it is common practice to append rules to iptables
# if these rules exist then anything appended after them will be ignored
/sbin/iptables -A INPUT -j DROP
/sbin/iptables -A FORWARD -j DROP
_s

/sbin/iptables -Z

#_fout ":${FUNCNAME}"
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
:<<\_c
configure iptables to drop all traffic except ssh for vagrant
http://www.thegeekstuff.com/2011/03/iptables-inbound-and-outbound-rules/
_c

function _iptables-input-drop-forward-drop-output-drop() {
#_fin ":${FUNCNAME}"

_debug_firewall "_iptables-input-drop-forward-drop-output-drop"

$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

_debug_firewall

_build_default_chain

[[ $DEBUG -gt 1 ]] && {
# log what falls through
/sbin/iptables -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT INPUT DROP: '
/sbin/iptables -A FORWARD -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT FORWARD DROP: '
/sbin/iptables -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT OUTPUT DROP: '
}

:<<\_s
# Log before dropping
$IPT -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IP INPUT drop: '
#$IPT -A INPUT  -j DROP
 
$IPT -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IP OUTPUT drop: '
#$IPT -A OUTPUT -j DROP

iptables -L
_s

:<<\_s
# these are redundant with their policy already set to drop
# also, they may cause problems
# it is common practice to append rules to iptables
# if these rules exist then anything appended after them will be ignored
/sbin/iptables -A INPUT -j DROP  
/sbin/iptables -A OUTPUT -j DROP  
/sbin/iptables -A FORWARD -j DROP
_s

/sbin/iptables -Z

#_fout ":${FUNCNAME}"
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _user_chain_flush() {

$IPT -F TCP_IN
$IPT -F TCP_OUT
$IPT -F UDP_IN
$IPT -F UDP_OUT
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _user_chain_log() {

sudo /sbin/iptables -I TCP_IN -j LOG --log-level 4 --log-prefix 'IPT TCP_IN start: '  # prepend
sudo /sbin/iptables -A TCP_IN -j LOG --log-level 4 --log-prefix 'IPT TCP_IN done: '  # append
sudo /sbin/iptables -I TCP_OUT -j LOG --log-level 4 --log-prefix 'IPT TCP_OUT start: '  # prepend
sudo /sbin/iptables -A TCP_OUT -j LOG --log-level 4 --log-prefix 'IPT TCP_OUT done: '  # append
}

function _user_chain_stop_log() {

sudo /sbin/iptables -D TCP_IN -j LOG --log-level 4 --log-prefix 'IPT TCP_IN start: '  # delete
sudo /sbin/iptables -D TCP_IN -j LOG --log-level 4 --log-prefix 'IPT TCP_IN done: '  # delete
sudo /sbin/iptables -D TCP_OUT -j LOG --log-level 4 --log-prefix 'IPT TCP_OUT start: '  # delete
sudo /sbin/iptables -D TCP_OUT -j LOG --log-level 4 --log-prefix 'IPT TCP_OUT done: '  # delete
}

# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
:<<\_c
# test user-defined chain method and various rules

these tests work by 
a) establish a full drop policy
b.1) flush the user-defined chains
b.2) enabling only what is necessary
b.3) run the test
b.4) repeat for each test
_c

function _test() {

trusted_network=192.168.1.0/24
trusted_nic=$MNIC_

# establish a full drop policy
. $PICASSO/install/system/iptables/default
_iptables-input-drop-forward-drop-output-drop

# ----------
_debug_firewall "cifs client test"

_user_chain_flush
# 445/TCP - SMB - Microsoft Directory Services (microsoft-ds) - Windows File and Print Sharing - Windows 2000 and XP - only for trusted networks 
# to turn off in Windows disable the NetBIOS over TCP/IP driver (NetBT.sys).
# https://www.grc.com/port_445.htm
#$IPT -A UDP_OUT -p udp -d $trusted_network --sport 445 -m state --state ESTABLISHED,RELATED -j ACCEPT
#$IPT -A UDP_IN -p udp -s $trusted_network --dport 445 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#$IPT -A TCP_OUT -p tcp -o $trusted_nic -d $trusted_network --sport 445 -m state --state ESTABLISHED,RELATED -j ACCEPT
#$IPT -A TCP_IN -p tcp -i $trusted_nic -s $trusted_network --dport 445 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
_tcp_in_accept -i $trusted_nic -s $trusted_network --dport 445 -m state --state NEW,ESTABLISHED,RELATED
_tcp_out_accept -o $trusted_nic --sport 445 -d $trusted_network -m state --state ESTABLISHED,RELATED
#ls $PICASSO/install
_debug_firewall "[OK] cifs client test"

# ----------
# http/https client

$IPT -A TCP_OUT -p tcp -m multiport --dports 80,443 -j ACCEPT
curl $GW  # no DNS
curl google.com  # yes DNS
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _troubleshoot() {

trusted_network=192.168.1.0/24
trusted_nic=$MNIC_

# full accept just so we can use cifs to access this script file - samba must be operative to access $PICASSO/install
IPT="/sbin/iptables"
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT

. $PICASSO/install/system/iptables/default

# establish a full drop policy
_iptables-input-drop-forward-drop-output-drop

# ----------
:<<\_s
_iptables-input-drop-forward-drop-output-drop
$IPT -A OUTPUT -p tcp --dport 445 -m state --state NEW,ESTABLISHED -j ACCEPT
ls $PICASSO/install
[FAIL] appending rule in default chain after its traffic has already been dropped
_s


# ----------
# ssh from a remote host into the vm via vagrant
_user_chain_flush
# Allow incoming SSH connection: vagrant(10.0.2.2) <-> $IFACE(tcp/22)
#_iptables "-A TCP_IN -p tcp -i $IFACE --dport 22 -s 10.0.2.2 -m state --state NEW,ESTABLISHED -j ACCEPT"
#_iptables "-A TCP_OUT -p tcp -o $IFACE --sport 22 -d 10.0.2.2 -m state --state ESTABLISHED -j ACCEPT"
_iptables "-A TCP_IN -p tcp -i $IFACE -s 10.0.2.2 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT"
_iptables "-A TCP_OUT -p tcp -o $IFACE -d 10.0.2.2 --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT"
# Allow incoming SSH connection from any lan ip($trusted_network) <-> $IFACE(tcp/22)
#_iptables "-A TCP_IN -p tcp -i $trusted_nic --dport 22 -s $trusted_network -m state --state NEW,ESTABLISHED -j ACCEPT"
#_iptables "-A TCP_OUT -p tcp -o $trusted_nic --sport 22 -d $trusted_network -m state --state ESTABLISHED -j ACCEPT"
if [[ -n "$trusted_nic" ]]; then
_iptables "-A TCP_IN -p tcp -i $trusted_nic -s $trusted_network --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT"
_iptables "-A TCP_OUT -p tcp -o $trusted_nic -d $trusted_network --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT"
fi

# ---------- ----------
$IPT -F TCP_IN
$IPT -F TCP_OUT
$IPT -F UDP_IN
$IPT -F UDP_OUT
$IPT -A TCP_IN -j ACCEPT
$IPT -A TCP_OUT -j ACCEPT
$IPT -A UDP_IN -j ACCEPT
$IPT -A UDP_OUT -j ACCEPT


# ---------- ----------


$IPT -A TCP_IN -p tcp --dport 135 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A TCP_OUT -p tcp --sport 135 -m state --state ESTABLISHED -j ACCEPT

$IPT -A TCP_IN -p tcp --dport 593 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A TCP_OUT -p tcp --sport 593 -m state --state ESTABLISHED -j ACCEPT


$IPT -A TCP_IN -p tcp --dport 135 -j ACCEPT
$IPT -A TCP_OUT -p tcp --sport 135 -j ACCEPT
$IPT -A TCP_IN -p tcp --sport 135 -j ACCEPT
$IPT -A TCP_OUT -p tcp --dport 135 -j ACCEPT

$IPT -A TCP_IN -p tcp --dport 593 -j ACCEPT
$IPT -A TCP_OUT -p tcp --sport 593 -j ACCEPT


# http/https server
$IPT -A TCP_IN -p tcp -m multiport --dports 80,443 -j ACCEPT
}

# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
_iptables_provision

_debug_firewall sdfs0fs8f
[[ -n $1 ]] && _${1}

_debug_firewall "iptables done"
:<<\_c
standard syslog levels...
log-level 0 - emergency
log-level 4 - warning
log-level 7 - debug
_c
:<<\_x
logging the INPUT and OUTPUT chains is too verbose, because it catches the ssh packets and everything else
sudo /sbin/iptables -I INPUT -j LOG --log-prefix 'IPT INPUT log all: '
sudo /sbin/iptables -I OUTPUT -j LOG --log-prefix 'IPT OUTPUT log all: '
sudo /sbin/iptables -D INPUT -j LOG --log-prefix 'IPT INPUT log all: '
sudo /sbin/iptables -D OUTPUT -j LOG --log-prefix 'IPT OUTPUT log all: '
_x
:<<\_x
the position of the TCP_IN and TCP_OUT links, in their respecitve INPUT and OUTPUT chains, means that standard protocol packets have already been filtered out before they are reached
thus, TCP_IN and TCP_OUT are effective points to trace from

add these rules after provisioning is complete

. $PICASSO/core/bin/iptables.sh
_user_chain_log
sudo journalctl -f | grep IPT

# anything falling through is an indication that the TCP_IN/TCP_OUT rules are not complete

_user_chain_stop_log
_x
:<<\_x
sudo journalctl -f | grep SRC=192.168.1.79

/sbin/iptables -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT INPUT DROP: '
/sbin/iptables -A FORWARD -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT FORWARD DROP: '
/sbin/iptables -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IPT OUTPUT ACCEPT: '
_x
:<<\_x
controller
_open_server_firewall MNIC 80 test 'TCP' "-m limit --limit 25/minute --limit-burst 100"
_x
