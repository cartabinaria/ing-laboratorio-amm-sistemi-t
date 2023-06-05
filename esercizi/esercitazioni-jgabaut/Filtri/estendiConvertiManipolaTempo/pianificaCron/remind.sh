#!/bin/bash +x
# NOTA: non dovrebbe mai succedere che il parametro sia errato
# visto che remind.sh viene schedulato dall'altro script via cron

test -f "$1" || {
	echo specificare il file delle scadenze come parametro
	exit 1
}

FILEALLARMI="$1"

# cron garantisce che remind.sh sia eseguito esattamente allo scadere 
# di ogni minuto, quindi il ciclo e tutte le precauzioni annesse non
# servono più

#NOW=0

#while sleep 20 ; do
	
#	[[ $(date +%M) -eq $NOW ]] && continue
	
#	NOW=$(date +%M)
	
#	# nota: i timestamp originali hanno la granularità del minuto,
#	# ma il tempo corrente considera i secondi, devo troncarli
#	# trick, ma si può fare in altri modi: la divisione per 60 restituisce un intero...	

	CURRENTMINUTE=$(( $(date +%s) / 60 * 60))

#	# nota: ci possono essere zero, una o più righe col timestamp corrente
#	# grep | while è il modo più semplice di gestirle, un'iterazione per ogni riga
#	# incluso il caso di zero iterazioni nei minuti per cui non ci sono corrispondenze

	egrep "^$CURRENTMINUTE" "$FILEALLARMI" | while read TIMESTAMP DATA ORA DESCRIZIONE ; do
		echo "$DESCRIZIONE scade il $DATA alle $ORA"
	done >> ~/promemoria
#done
