#!/bin/bash

#Realizzare uno script che legga da un elenco di IP da un file 
#(il cui nome è passato come parametro) 
#e restituisca su STDOUT l'IP della macchina che ha meno processi in esecuzione

#$1 file con gli ip

# test numero argomenti
 if [[ $# -ne 1 ]] ; then
        echo "Numero argomenti errato"; exit 1;
 fi

# $1 deve essere file standard e con path assoluto 
if ! [[ -f "$1" && "$1" =~ ^/ ]] ; then
	echo "$1 non è un file con path assoluto"
	exit 1
fi

MIN=9999999999;
IPMIN=0;
cat "$1" | ( while read L ; {
	#Controlla se $L è un ip ben formato
	ip="$L"

	if [[ "$ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then {
	:
	}
	else {
	  echo "$ip is not a valid IP address"
	  continue;
	}
	fi
	
	F=$(mktemp)
	N=$( snmpget -v 1 -c public "$ip" NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"procCount\" | cut -f4 -d' ' )
	
	if [[ $N -lt $MIN ]] ; then { MIN=$N ; IPMIN="$ip" } ; fi 
} done


echo "$IPMIN"
) #importante avere subshell esplicita per usare variabili fuori dal sottoprocesso che il while crea!
