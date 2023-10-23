#!/bin/bash

#Mettiamo in $1 indirizzo dell'agent e in $2 nome del processo

# test numero argomenti
 if [[ $# -ne 2 ]] ; then
        echo "Numero argomenti errato"; exit 1;
 fi

#Controllo argomento ip
ip="$1"

if [[ "$ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then {
:
}
else {
  echo "$ip is not a valid IP address"
  exit 1
}
fi
#diamo per scontato sia che $2 contenga un nome di processo,
# sia che il processo sia tra quelli controllati da SNMP...

F=$(mktemp)
snmpwalk -v 1 -c public "$ip" .1.3.6.1.4.1.2021.2 > $F #scriviamo tabella proc nel file temporaneo, con gli OID alfabetici

#ricava OID della cella con il conteggio del processo:
# facendo grep della linea che finisce con il nome del processo;
# ricavando con cut la sola parte di OID;
# e sostituendo il penultimo livello dell'OID da prNames a prCount.
# Così l'ultimo livello dell'OID resta il numero che identifica le righe relative al processo voluto!

OIDcount=$(grep "STRING: $2$" "$F" | cut -f1 -d' ' | sed 's/prNames/prCount/') 
NUM=$(snmpget -v 1 -c public "$ip" "$OIDcount" | cut -f4 -d' ') 
echo "Numero istanze di $2: $NUM" 

#per verificare se il numero di istanze attive è entro i limiti, verifico se prErrorFlag vale noError(0)

OIDflag=$(echo "$OIDcount" | sed 's/prCount/prErrorFlag/')
if [[ $(snmpget -v 1 -c public "$ip" "$OIDflag") =~ noError"(0)"$ ]] ; then {
echo "Soglia non violata per $2";
} else {
echo "Soglia violata per $2" 
}
fi
