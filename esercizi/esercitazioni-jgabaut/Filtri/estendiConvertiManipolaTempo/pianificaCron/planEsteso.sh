#!/bin/bash +x
# formato record calendario 
# YYYY-MM-DD HH:MM DESCRIZIONE
# Questo script può accertarsi che remind.sh venga eseguito da cron. Per fare ciò
# estrae il file di configurazione attivo di cron, e prima di aggiungere la riga 
# che schedula remind.sh, ripulisce il file di cron da eventuali righe che già 
# siano presenti con la stessa direttiva, per evitare di duplicarle. Infine 
# installa la nuova configurazione.

function removeAlerts() {
#$1 file calendario
#$2 file allarmi
# formato record calendario 
# YYYY-MM-DD HH:MM DESCRIZIONE
# formato record allarmi
# SECONDI YYYY-MM-DD HH:MM DESCRIZIONE

test -f "$1" || {
	echo "$FUNCNAME" il primo parametro deve essere un file calendario esistente
	exit 1
}
test -f "$2" || {
	echo "$FUNCNAME" il secondo parametro deve essere un file allarmi esistente
	exit 1
}

TMPALARM=$(mktemp) #crea file notifiche temporaneo

cat "$2" | while read SCADENZA DATA ORA DESCRIZIONE
do
	ROWALERT="$SCADENZA $DATA $ORA $DESCRIZIONE"
	ROWCAL="$DATA $ORA $DESCRIZIONE"
	grep -qx "$ROWCAL" "$1" && echo "$ROWALERT" >> "$TMPALARM" # append degli eventi presenti in calendario
done

echo "$TMPALARM" > "$2" #sovrascrive file allarmi
rm -f "$TMPALARM"  #elimina file allarmi temporaneo

}

test -f "$1" || { #controllo parametri
	echo il primo parametro deve essere un file calendario esistente
	exit 1
}

test "$2" || {
	echo servono due parametri, il secondo deve essere un nome di file delle scadenze da creare o aggiornare
	exit 2
}

CALENDARIO="$1"
FILEALLARMI="$2"

removeAlarms "$CALENDARIO" "$FILEALLARMI" # rimuove eventi non presenti in calendario da file allarmi


cat "$CALENDARIO" | while read DATA ORA DESCRIZIONE
do
	SCADENZA=$(date +%s -d "$DATA $ORA") # conversione in secondi dal 1970-01-01 01:00
	RIGAGIORNOPRIMA="$(( SCADENZA - 24*60*60 )) $DATA $ORA $DESCRIZIONE"
	RIGAORAPRIMA="$(( SCADENZA - 60*60 )) $DATA $ORA $DESCRIZIONE"
	grep -qx "$RIGAGIORNOPRIMA" "$FILEALLARMI" || echo "$RIGAGIORNOPRIMA" >> "$FILEALLARMI" #accoda al file delle scadenze solo quelle che non sono gia presenti
	grep -qx "$RIGAORAPRIMA" "$FILEALLARMI" || echo "$RIGAORAPRIMA" >> "$FILEALLARMI"
done

TMPCRON=$(mktemp)
RIGACRON="* * * * * $HOME/remind.sh $FILEALLARMI"

crontab -l | grep -Fvx "$RIGACRON" > "$TMPCRON" 
#grep -F disattiva RE e cerca il parametro letteralmente, 
# -x fa match solo con l'intera riga, 
# -v restituisce solo le righe che NON contengono l'espressione; quindi sovrascriviamo il file temporaneo togliendo eventuali righe con la stessa direttiva

echo "$RIGACRON" >> "$TMPCRON" #aggiungiamo la direttiva al file temporaneo

crontab "$TMPCRON" #prende file temporaneo come parametro
rm -f "$TMPCRON"
