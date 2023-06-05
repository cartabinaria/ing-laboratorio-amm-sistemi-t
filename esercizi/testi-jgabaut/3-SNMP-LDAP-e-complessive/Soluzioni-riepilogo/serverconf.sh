#!/bin/bash
#
# pulisco e blocco tutto (in fondo)...
iptables -F
#
# tranne il traffico interno!
#
iptables -I INPUT -i lo -j ACCEPT
iptables -I OUTPUT -o lo -j ACCEPT
#
# ed il traffico entrante dalla rete locale
#
iptables -I INPUT -s 10.9.9.0/24 -i eth1 -j ACCEPT
iptables -I OUTPUT -m state -d 10.9.9.0/24 -o eth1 --state ESTABLISHED,RELATED -j ACCEPT
#
# ed il traffico di management
#
iptables -I INPUT -s 192.168.56.1 -i eth3 -j ACCEPT
iptables -I OUTPUT -m state -d 192.168.56.1 -o eth3 --state ESTABLISHED,RELATED -j ACCEPT
#
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP


