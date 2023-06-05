#!/bin/bash
#
# dato come primo parametro un hostname, restituire il numero di processi rilevato su tale macchina

snmpget -v 1 -c public "$1" 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."sshnum"' | awk -F 'STRING: ' '{ print $2 }' 
# SU OGNI MACCHINA REMOTA CONFIGURARE L'AGENT CON
#  extend-sh sshnum  ps haux | wc -l

