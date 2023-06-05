#!/bin/bash +x
#$@ n comandi da eseguire
if [[ $# -lt 1 ]] ; then { 
	echo "Usage: $0 command1 [...commandN]" ; 
	exit 1 ; 
} ; 
fi #controlla ci sia almeno un argomento

#predisponiamo handler perché chiuda tutti i figli se viene terminato lo script
trap 'kill $(jobs -pr) 2>/dev/null ' SIGINT SIGTERM EXIT ; 

cat /dev/null > log

for COMANDO in "$@" ; do
	
	# COMANDO deve essere eseguibile, file standard e con path assoluto 
	if ! [[ -x "$COMANDO" && -f "$COMANDO" && "$COMANDO" =~ ^/ ]] ; then
		echo "$COMANDO" non è un eseguibile con path assoluto
		exit 1
	fi
	echo "iterazione per comando $COMANDO"
	$COMANDO & PID[$!]=$(which $COMANDO | rev | cut -f1 -d/ | rev) ; #come controlliamo se un argomento è comando valido? come riconoscere opzioni?

done

#echo contenuto e indici array programmi
#echo ${PID[@]};
#echo ${!PID[@]};

while sleep 5 ; do #indicazione di 5 secondi è imprecisa, dovremmo usare altri metodi (si pensi alla durata dell'esecuzione ciclo che è non-0, prima che il ciclo riparta)
FLAG=0;
	for pid in ${!PID[@]} ; do
		COMANDOATTUALE=$(ps hp $pid | cut -f2 -d: | cut -f2 -d' '); echo "PID: $pid COMANDO: $COMANDOATTUALE" ; 
		if [[ "$COMANDOATTUALE" = "${PID[$pid]}" ]] ; then #controlla che pid corrisponda ancora al comando 
		{
			STATO=`ps hp $pid | awk '{ print $3 }'` # opzione h disabilita header, opzione p seleziona con PID
			if test -z "$STATO" ; then STATO=terminato ; else FLAG=1; fi # opzione z controlla che lunghezza sia zero, quindi FLAG si imposta a 1 quando c'è un comando ancora running
			echo "Stato del processo $pid: $STATO" | tee -a log #tee scrive sia su stdout che sul file indicato (come tubo a T, due uscite)
		} elif [[ -z $COMANDOATTUALE ]] ; then 			{		
			echo "Stato del processo $pid: PID vuoto" | tee -a log #caso di programma terminato ma pid occupato da altro processo
		} else {
			echo "Stato del processo $pid: ${PID[$pid]} sostituito da "$COMANDOATTUALE"" | tee -a log #caso di programma terminato ma pid occupato da altro processo
		}
		fi	
	done	
# if test "$STATO1" = "terminato" -a "$STATO2" = "terminato" ; then break ; fi
if [[ FLAG -eq 0 ]] ; then break ; fi #uscita dal ciclo quando FLAG non è stato settato
done
