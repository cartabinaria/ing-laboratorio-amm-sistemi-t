#!/bin/bash

# estensioni possibili:
# gestire più connessioni dallo stesso client
# facilitare il kill facendo scrivere il pid a toctoc da qualche parte

IPROUTER=10.1.1.254

function debug() {
	# commentare per disattivare l'output diagnostico
	# o a piacere sostituire con logger...
	echo "$@" >&2
}

function elenca_connessioni() {
	# riporta l'elenco degli IP (e porta?) connessi in ssh al router
	ss -nt | egrep "^ESTAB.*$IPROUTER:22[[:space:]]" | awk '{ print $5 }' | cut -f1 -d: 

}

function snmp_check() {
	snmpwalk -v 1 -c public $1 .1.3.6.1.4.1.2021.2 > /tmp/snmp.$$
	# individua quale riga della tabella si riferisce a rsyslogd
	RIGA=$(egrep "prNames.*rsyslogd" /tmp/snmp.$$ | awk -F "prNames." '{ print $2 }' | awk '{ print $1 }')
	# il comando seguente ritorna exit code 0 (true) se c'è match, senza produrre output: ideale per l'uso con if
	grep -q "prErrorFlag.$RIGA = INTEGER: noError(0)" /tmp/snmp.$$
}
 	


function abilita_traffico() {
	# consentano al client ($1) di attraversare il router solo per connettersi al server ($2) sulla porta remota ($3) specificata nel file. Porre attenzione alla direzione delle connessioni. Vista la limitazione di traffico sui server, mascherare i pacchetti che dai client attraversano router.
	debug abilitazione traffico da $1 a $2:$3
	/root/openclose.sh I $1 $2 $3
	#
	# innesco la chiusura della connessione e memorizzo il job id in un file
	#
	echo "/root/openclose.sh D $1 $2 $3" | at now + 5 minutes 2>&1 | grep ^job | awk '{ print $2 }' > /tmp/timer_$1_$2_$3
	debug attivato watchdog con at job id $(cat /tmp/timer_$1_$2_$3)
}



function chiudi_connessione () {
	#  cancellare il file creato dal client e disconnettere forzatamente la connessione ssh agendo sul server sshd
	debug rimozione /tmp/$1
	rm -f /tmp/$1
	ss -ntp | egrep "^ESTAB.*$IPROUTER:22[^0-9]+$1:" | awk -F '\(\(' '{ print $2 }' | sed -e 's/pid=/\n/g' | grep '^[1-9]' | cut -f1 -d, | while read P ; do
		debug termino $P per chiudere la connessione 
		kill -9 $P
	done
	# potrei usare pid negativo per killare l'intero process group
}


while sleep 5 ; do
  for IP in $(elenca_connessioni) ; do
    debug trovata connessione da $IP
    if test -f /tmp/$IP ; then
      debug trovato file corrispondente /tmp/$IP
      SERVER=$(cat /tmp/$IP | cut -f1 -d' ')
      if snmp_check $SERVER ; then
  	debug snmp check positivo su $SERVER
	PORTA=$(cat /tmp/$IP | cut -f2 -d' ')
	abilita_traffico $IP $SERVER $PORTA
	chiudi_connessione $IP
      fi
    fi
  done
done

