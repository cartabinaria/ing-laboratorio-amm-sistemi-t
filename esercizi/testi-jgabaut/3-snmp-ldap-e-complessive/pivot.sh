#!/bin/bash
#
# sul network element $1 gira un processo di nome $2
# scoprire via SNMP quante istanze sono in esecuzione

# aggiungere check parametri

#versione con una get in meno ma file temporaneo
F=$(mktemp)
snmpwalk -v 1 -c public "$1" .1.3.6.1.4.1.2021.2 > "$F"
OID=$(grep "STRING: $2$" "$F" | awk '{ print $1 }' | sed 's/prNames/prCount/')
grep "^$OID" "$F" | awk -F 'INTEGER: ' '{ print $2 }' 

# versione supercompatta
snmpget -v 1 -c public "$1" $(snmpwalk -v 1 -c public "$1" .1.3.6.1.4.1.2021.2 | grep "STRING: $2$" | awk '{ print $1 }' | sed 's/prNames/prCount/') | awk -F 'INTEGER: ' '{ print $2 }'

