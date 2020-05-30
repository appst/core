#_open_server_firewall MNIC "$port" "xvnc" 'TCP'
sudo /sbin/iptables -A INPUT -p tcp -j ACCEPT --dport $port -m conntrack --ctstate NEW,ESTABLISHED
sudo /sbin/iptables -A OUTPUT -p tcp -j ACCEPT --sport $port -m conntrack --ctstate ESTABLISHED
#sudo /sbin/iptables -A TCP_IN -p tcp -j ACCEPT --dport $port -m conntrack --ctstate NEW,ESTABLISHED
#sudo /sbin/iptables -A TCP_OUT -p tcp -j ACCEPT --sport $port -m conntrack --ctstate ESTABLISHED
#_tcp_in_accept -i $MNIC_ -s ${MNIC_NETWORK}/${MNIC_PREFIX} -m multiport --dports $ports -m conntrack --ctstate NEW,ESTABLISHED -m comment --comment "${comment}-server"
#_tcp_out_accept -o $MNIC_ -d ${MNIC_NETWORK}/${MNIC_PREFIX} -m multiport --sports $ports -m conntrack --ctstate ESTABLISHED -m comment --comment "${comment}-server"
:<<\_x
ports=5901

function _tcp_in_accept() {
sudo /sbin/iptables -A TCP_IN -p tcp -j ACCEPT $@ 
}

function _tcp_out_accept() {
sudo /sbin/iptables -A TCP_OUT -p tcp -j ACCEPT $@ 
}

_tcp_in_accept -m multiport --dports $ports -m conntrack --ctstate NEW,ESTABLISHED
_tcp_out_accept -m multiport --sports $ports -m conntrack --ctstate ESTABLISHED

_tcp_in_accept -s ${MNIC_NETWORK}/${MNIC_PREFIX} -m multiport --dports $ports -m conntrack --ctstate NEW,ESTABLISHED
_tcp_out_accept -d ${MNIC_NETWORK}/${MNIC_PREFIX} -m multiport --sports $ports -m conntrack --ctstate ESTABLISHED

_tcp_in_accept -i $MNIC_ -s ${MNIC_NETWORK}/${MNIC_PREFIX} -m multiport --dports $ports -m conntrack --ctstate NEW,ESTABLISHED
_tcp_out_accept -o $MNIC_ -d ${MNIC_NETWORK}/${MNIC_PREFIX} -m multiport --sports $ports -m conntrack --ctstate ESTABLISHED
_x


----------
sudo bash -c "iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X; iptables -t mangle -F; iptables -t mangle -X; iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT"
sudo iptables -L


---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
sudo iptables-save > /tmp/iptables
sudo cat /tmp/iptables


---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
function _firewall_iptables3() {

NTP_IP=$(_dns_get ntp)
DB_IP=$(_get_host_ip hostdb)
MQ_IP=$(_get_host_ip hostmq)

cat <<EOF > /etc/sysconfig/iptables
*filter
    :INPUT ACCEPT [0:0]
    :FORWARD ACCEPT [0:0]
    :OUTPUT ACCEPT [0:0]
    -A TCP_IN -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    -A TCP_IN -p icmp -j ACCEPT
    -A TCP_IN -i lo -j ACCEPT
-A TCP_IN -s $NTP_IP -p udp -m udp --sport 123 -j ACCEPT
    -A TCP_IN -p tcp -m multiport --dports 3260 -m comment --comment 'Cinder' -j ACCEPT 
    -A TCP_IN -p tcp -m multiport --dports 80 -m comment --comment 'Horizon' -j ACCEPT 
    -A TCP_IN -p tcp -m multiport --dports 9292 -m comment --comment 'Glance' -j ACCEPT 
    -A TCP_IN -p tcp -m multiport --dports 5000,35357 -m comment --comment 'Keystone' -j ACCEPT 
#    -A TCP_IN -p tcp -m multiport --dports 3306 -m comment --comment "001 mariadb server" -j ACCEPT 
-A TCP_IN -p tcp -s $DB_IP --dport 3306 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    -A TCP_IN -p tcp -m multiport --dports 6080 -m comment --comment 'NovaProxy' -j ACCEPT 
    -A TCP_IN -p tcp -m multiport --dports 8770:8780 -m comment --comment 'NovaApi' -j ACCEPT 
#    -A TCP_IN -p tcp -m multiport --dports 9696 -m comment --comment 'Neutron' -j ACCEPT 
#    -A TCP_IN -p tcp -m multiport --dports 5672 -m comment --comment "001 qpid server" -j ACCEPT 
-A TCP_OUT -p tcp -m tcp --sport 5672 -j ACCEPT
#    -A TCP_IN -p tcp -m multiport --dports 8700 -m comment --comment "001 metadata server" -j ACCEPT 
    -A TCP_IN -m conntrack --ctstate NEW -m tcp -p tcp --dport 22 -j ACCEPT
    -A TCP_IN -m conntrack --ctstate NEW -m tcp -p tcp --dport 5900:5999 -j ACCEPT
    -A TCP_IN -j REJECT --reject-with icmp-host-prohibited
    -A TCP_IN -p gre -j ACCEPT 
    -A TCP_OUT -p gre -j ACCEPT
    -A FORWARD -j REJECT --reject-with icmp-host-prohibited
    COMMIT
EOF
iptables-restore < /etc/sysconfig/iptables
}
