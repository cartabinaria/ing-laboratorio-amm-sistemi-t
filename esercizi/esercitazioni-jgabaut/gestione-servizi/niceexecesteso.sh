#!/bin/bash
# 
PATHCOMANDO="$(readlink -f "${BASH_SOURCE}")"
TRIES="$1"
SOGLIA="$2"
COMANDO="$3"

# testare se $TRIES è un numero
if ! [[ "$TRIES" =~ ^[0-9]+$ ]] ; then
	echo "$1 non è un numero"
	exit 1
fi
# testare se $SOGLIA è un numero
if ! [[ "$SOGLIA" =~ ^[0-9]+$ ]] ; then
	echo "$2 non è un numero"
	exit 2
fi

# $3 deve essere eseguibile, file standard e con path assoluto 
# per evitare problemi con l'environment di atd
if ! [[ -x "$COMANDO" && -f "$COMANDO" && "$COMANDO" =~ ^/ ]] ; then
	echo "$COMANDO" non è un eseguibile con path assoluto
	exit 3
fi

#occorre verificare separatore tra i decimali in base al locale...
TOT=$(uptime | cut -f5 -d: |cut -f1 -d, | cut -f1 -d$(locale decimal_point))

if $TOT -lt "$SOGLIA" ; then 
	#true, tot e' sotto soglia
	shift
	shift
	eval "$@" || { echo "errore durante l'esecuzione di $COMANDO"; exit 1; } ;
else { 
	let TRIES--
	shift	#scartiamo parametro tentativi per reinserirlo modificato
	echo "$PATHCOMANDO" "$TRIES" "$@" | at now + 2 minutes 2>&1 ;

}

fi
