#!/bin/bash

# da eseguire ogni minuto via cron
# soglia in pacchetti al minuto passata come primo parametro, o default impostato qui di seguito

soglia=1000

test "$1" -gt 0 2>/dev/null && soglia=$1

# aver creato catene con nomi riconoscibili aiuta 
# 1) a elencarle
# 2) a estrarre dal nome direttamente i parametri identificativi della connessione

for CATENA in $(iptables -nL | grep "^Chain CONTA-" | awk '{ print $2}') ;do

	# -Z -vnxL restituisce il valore corrente dei contatori
	# e atomicamente li azzera

	PACCHETTI=$(iptables -Z -vnxL $CATENA | grep -v ^Zeroing | tail -1 | awk '{ print $1 }')
	if test "$PACCHETTI" -gt "$soglia" ; then
		SIP=10.1.1.$(echo $CATENA | cut -f2 -d-) 	
		DIP=10.9.9.$(echo $CATENA | cut -f3 -d-) 	
		SPT=$(echo $CATENA | cut -f4 -d-) 	
		DPT=$(echo $CATENA | cut -f5 -d-) 	
		/root/log_user.sh $SIP $DIP $SPT $DPT
	else	
done

