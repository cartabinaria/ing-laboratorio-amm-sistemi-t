#!/bin/bash

# Realizzare uno script su Client che accetti come parametri
# "IP1:PORTA1" "IP2:PORTA2" e recuperi, via SNMP, il nome 
# dell'utente che su Server sta impegnando la connessione da
# essi definita

# Soluzione base
# richiede lato server, in /etc/snmp/snmpd.conf
# extend socket /usr/bin/sudo /bin/ss -ntp
# extend sshnum ps haux

MYPID=$(snmpget -v 1 -c public 192.168.56.203 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."socket"'  | egrep " $1 +$2 " | awk -F "pid=" '{ print $2 }' | cut -f1 -d,)

snmpget -v 1 -c public 192.168.56.203 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."sshnum"' | egrep "^[^ ]+ +$MYPID " | awk '{ print $1 }'

# Proposte di miglioramento:
# 
# 1) considerare tutti i "pid=" di ss, non solo il primo
#
# 2) condensare in una singola extend tutto il preprocessing 
#    necessario in modo da utilizzare una singola snmpget
# 
# 3) da esplorare senza garanzie: si può usare nsExtendInput
#    per inviare all'agent i parametri, e ricevere direttamente
#    una risposta che non richieda ulteriore filtraggio?
