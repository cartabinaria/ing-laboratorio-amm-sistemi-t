#grep -F disattiva RE e cerca il parametro letteralmente, 
# -x fa match solo con l'intera riga, 
# -v restituisce solo le righe che NON contengono l'espressione;
TEMP=$(mktemp)
grep -Fvx "local1.=info  /var/log/sd.log" "/etc/rsyslog.d/mylog.conf" | while read RIGA; do {
	echo "$RIGA" >> "$TEMP"
} done
	mv "$TEMP" "/etc/rsyslog.d/mylog.conf"
	rm -f $TEMP

#elimina la riga dal file
