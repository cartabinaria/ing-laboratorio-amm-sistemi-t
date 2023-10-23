#!/bin/bash
#
# pulisco
iptables -F
#
# blocco tutto (in fondo)...
#
# tranne il traffico interno!
#
iptables -I INPUT -i lo -j ACCEPT
iptables -I OUTPUT -o lo -j ACCEPT
#
# ed il traffico indispensabile per toctoc
#
iptables -I INPUT -p tcp -s 10.1.1.0/24 -d 10.1.1.254 --dport 22 -j ACCEPT
iptables -I OUTPUT -m state -p tcp -d 10.1.1.0/24 -s 10.1.1.254 --sport 22 --state ESTABLISHED -j ACCEPT
iptables -I OUTPUT -m state -d 10.1.1.0/24 -s 10.1.1.254 --state RELATED -j ACCEPT
#
# ed il traffico indispensabile per l'estensione SNMP di avanti
#
iptables -I OUTPUT -p udp -s 10.9.9.254 -d 10.9.9.0/24 --dport 161 -j ACCEPT
iptables -I INPUT -m state -p udp -d 10.9.9.254 -s 10.9.9.0/24 --sport 161 --state ESTABLISHED -j ACCEPT
#
# ed il traffico di management
#
iptables -I INPUT -s 192.168.56.1 -i eth3 -j ACCEPT
iptables -I OUTPUT -m state -d 192.168.56.1 -o eth3 --state ESTABLISHED,RELATED -j ACCEPT
#
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

