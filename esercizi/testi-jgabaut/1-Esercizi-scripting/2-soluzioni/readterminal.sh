#!/bin/bash

# con FOR, verificare che si comporta erroneamente se ci sono spazi nel campo letto da passwd
for U in $(cut -d: -f5 /etc/passwd) ; do
	echo Cosa vuoi fare con l\'utente $U\?
	read RISPOSTA
	echo Eseguo $RISPOSTA su $U
done

# con WHILE il problema è risolto, ma read va alimentato da terminale altrimenti legge righe di passwd
T=`ps h $$ | awk '{ print $2 }'`
cut -f5 -d: /etc/passwd | sort -n | while read U ; do 
	echo Cosa vuoi fare con l\'utente $U\?
	read risposta < /dev/$T
	echo $risposta
done









