#!/bin/bash +x
# formato record calendario 
# YYYY-MM-DD HH:MM DESCRIZIONE
# Manteniamo la prima parte per aggiornare il calendario, senza bisogno di un file 
# delle scadenze, mantenendo una copia di backup solo al fine di capire cosa era 
# gia presente e cosa e stato aggiunto.

test -f "$1" || { #controllo parametri
	echo il primo parametro deve essere un file calendario esistente
	exit 1
}

# Non ci serve file scadenze
#test "$2" || { 
#	echo servono due parametri, il secondo deve essere un nome di file delle scadenze da creare o aggiornare
#	exit 2
#}

CALENDARIO="$1"
#FILEALLARMI="$2"

test -f "OLD-$CALENDARIO" || touch "OLD-$CALENDARIO" #verifica/crea file backup calendario

cat "$CALENDARIO" | while read DATA ORA DESCRIZIONE
do
	SCADENZA=$(date +%s -d "$DATA $ORA") # conversione in secondi dal 1970-01-01 01:00
	
	#RIGAGIORNOPRIMA="$(( SCADENZA - 24*60*60 )) $DATA $ORA $DESCRIZIONE"
	#RIGAORAPRIMA="$(( SCADENZA - 60*60 )) $DATA $ORA $DESCRIZIONE"
	# Dopo aver calcolato "meno un giorno" e "meno un'ora" bisogna riconvertire i timestamp 
	# in formato "YYMMDDhhmm", quello piu pratico in
	# questo caso, tra i vari accettati da at.
	# @ operatore di date per cambiare da epoch a timestamp

	GIORNOPRIMA="$(date '+%Y%m%d%H%M' -d @$(( SCADENZA - 24*60*60 )) )"
	ORAPRIMA="$(date '+%Y%m%d%H%M' -d @$(( SCADENZA - 60*60 )) )"
	
	# L'intera logica e attuabile da un singolo script, ma i job schedulati con at allo stesso minuto rischiano 
	# di scrivere concorrentemente sullo stesso file, per cui è necessario utilizzare un lock. Il primo processo 
	# a lanciare flock $HOME/promemoria acquisisce un lock esclusivo, se altri fanno lo stesso restano in attesa
        # finche il lock non viene rilasciato.

	grep -qx "$DATA $ORA $DESCRIZIONE" "OLD-$CALENDARIO" || { # -q quiet, -x matcha solo linee intere. Se non trova match entra nella sequenza
		at -t "$GIORNOPRIMA" <<< "flock $HOME/promemoria echo '$DESCRIZIONE scade il $DATA alle $ORA' >>
$HOME/promemoria" # at si aspetta come parametro il tempo a cui fare il comando e poi prende da stdin il comando da eseguire, in questo caso 
		at -t "$ORAPRIMA" <<< "flock $HOME/promemoria echo '$DESCRIZIONE scade il $DATA alle $ORA' >>
$HOME/promemoria"
	}
done

cat "$CALENDARIO" > "OLD-$CALENDARIO"
