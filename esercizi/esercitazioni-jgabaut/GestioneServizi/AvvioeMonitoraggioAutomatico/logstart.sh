if [[ -f /etc/rsyslog.d/mylog.conf ]] ; then {
	TEMP=$(mktemp)
	grep -Fvx "local1.=info  /var/log/sd.log" "/etc/rsyslog.d/mylog.conf" | while read RIGA; do {
		echo "$RIGA" >> "$TEMP"
	} done
	mv "$TEMP" "/etc/rsyslog.d/mylog.conf"
	rm -f $TEMP
} 
fi
#ricopia il file eliminando la riga prima di aggiungerla, nel caso il file già esistesse

echo "local1.=info  /var/log/sd.log" >> /etc/rsyslog.d/mylog.conf

