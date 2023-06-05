#!/bin/bash +x
#Se logrotate.sh  si rileva lanciato da terminale (man tty), 
#
#    configura rsyslog per dirigere i messaggi etichettati local1 con priorità non inferiore a 
#	warning sul file /var/log/my.log
#    
#    configura la cron table di root per esegure se stesso ogni giorno lavorativo alle 23:00
#    
#In caso contrario, effettua la "rotazione" del file /var/log/my.log 
#
#    rinomina eventuali file /var/log/my.log.N.bz2 in /var/log/my.log.N+1.bz2 
#	(per ogni N esistente)
#    rinomina /var/log/my.log in /var/log/my.log.1 e lo comprime con bzip2
#    ricarica rsyslogd (più in generale il processo che vi sta scrivendo man fuser)    
    
shopt -s extglob    #Usiamo extglob per selezionare moltiplicatori nella pathname expansion del for
    
if ! [[  $(tty) =~ "not a tty" ]] ; then {
	echo "local1.warning	/var/log/my.log" > /etc/rsyslog.d/mylog.conf
	PERIODO='0 23 * * 1-5'
	COMANDO=$(readlink -f "$0")
	sudo echo "$PERIODO $COMANDO root" >> /etc/crontab
} else {
	#rinomina file facendo N=N+1
	for F in /var/log/my.log.+([[:digit:]]).bz2 ; do { #una o più occorrenze di digit, serve shopt extglob
		N=$(cut -f3 -d. <<< "$F")
		let N++		
		mv "$F" "/var/log/my.log.$N.bz2"		
	}
	done
	FILE="/var/log/my.log"
	if [[ -f "$FILE" ]] ; then { #testa se esiste il file
		mv "$FILE" "$FILE".1	
		bzip2 -c "$FILE".1 > "$FILE".1.bz2
	} else {
		echo "File /var/log/my.log inesistente" ; 
		exit 1;
	}
	fi
	
	sudo systemctl restart rsyslog
	#ricaricare rsyslogd. Come fare a riavviare il processo che sta scrivendo sul file, dopo aver controllato?
}	
fi


