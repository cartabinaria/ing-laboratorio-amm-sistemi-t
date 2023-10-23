#!/bin/bash

# sull'agent: 
#
# file /etc/sudoers
# snmp    ALL=NOPASSWD:/sbin/iptables -vnL
#
# si può testare con
# las@Router:~$ sudo -H -u snmp /bin/bash
# snmp@Router:/home/las$ sudo /sbin/iptables -vnL 
#
# file /etc/snmp/snmpd.conf
# extend-sh ipt /usr/bin/sudo /sbin/iptables -vnL

snmpget -v 1 -c public localhost NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"ipt\"

