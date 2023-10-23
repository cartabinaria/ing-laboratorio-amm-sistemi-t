#!/bin/bash
# uno script che senza sosta, ogni 10 secondi, logga un messaggio etichettato local1.info contenente (su di un'unica riga) la quantità di RAM libera e la tripla username/pid/comando del processo che sta consumando più CPU
#

while true ; do {

	#ricava RAM libera come numero di byte
	FREERAM=$(free | head -n 2 | tail -n +2 | awk '{print $3}')

	#crea file temporaneo e vi scrive la riga di interesse, quella relativa al processo che consuma più CPU
	TEMP=$(mktemp)
	top -o %CPU -b -n2 | tail -n +8 | head -n 1 > $TEMP

	#estrae i campi di interesse dalla linea messa nel file, in base alla posizione
	USER=$(cat $TEMP | awk '{print $2}')
	PID=$(cat $TEMP | awk '{print $1}')
	COMMAND=$(cat $TEMP | awk '{print $12}')

	#logga messaggio
	logger -p local1.info "$FREERAM, $USER $PID $COMMAND"
	
	#elimina file temporaneo
	rm -f $TEMP
	
	#attesa attiva in sleep crea problemi?
	sleep 10;
}
done
