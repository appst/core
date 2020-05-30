#!/bin/bash
:<<\_c
firewalld is just a front-end for iptables; therefore, I can mix iptables commands in with it
_c

. $PICASSO/core/bin/iptables.sh

# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
:<<\_s
use iptables.sh version so i don't have to maintain duplicate source here

function _build_default_chain() {
firewall-cmd --permanent --direct --add-chain ipv4 filter TCP_IN
firewall-cmd --permanent --direct --add-chain ipv4 filter TCP_OUT
firewall-cmd --permanent --direct --add-chain ipv4 filter UDP_IN
firewall-cmd --permanent --direct --add-chain ipv4 filter UDP_OUT
}
_s


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _firewalld_provision() {

:
#_build_default_chain  # via iptables.sh
}


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _firewalld_test() {

# establish a full drop policy
#_iptables-input-drop-forward-drop-output-drop

# ----------
echo "cifs client test"
echo "TODO"
:<<\_s
_user_chain_flush

# firewall-cmd [--permanent] --direct --add-rule { ipv4 | ipv6 | eb } <table> <chain> <priority> <args>
firewall-cmd --add-port=445/udp UDP_OUT
firewall-cmd --add-port=9876/tcp
firewall-cmd --add-forward-port=port=445:proto=udp:toport=445:toaddr=192.168.1.0/24

_iptables "-A UDP_OUT -d 192.168.1.0/24 -p udp --sport 445 -m state --state ESTABLISHED,RELATED -j ACCEPT"
_iptables "-A TCP_OUT -o $NIC -d 192.168.1.0/24 -p tcp --sport 445 -m state --state ESTABLISHED,RELATED -j ACCEPT"
_iptables "-A UDP_IN -s 192.168.1.0/24 -p udp --dport 445 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT"
_iptables "-A TCP_IN -i $NIC -s 192.168.1.0/24 -p tcp --dport 445 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT"
echo "[OK] cifs client test"
_s

}

_firewalld_provision
