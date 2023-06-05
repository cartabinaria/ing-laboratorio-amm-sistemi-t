#!/bin/bash
# dato un file nel formato:
# nomeutente1 indirizzo1
# datanascita1 telefono1 
# nomeutente2 indirizzo2
# datanascita2 telefono2 
# ....
# produrre in output
# nomeutente1 telefono1
# nomeutente2 telefono2
# ...
# se il nome del file è passato come parametro:

cat "$1" | while read NOME INDIRIZZO ; do
	read DATA TELEFONO
	echo $NOME $TELEFONO
done

# Se i campi possono contenere spazi, non funziona più.
# Nel caso, ipotizzando che il separatore di campi sia ":"

cat "$1" | while read RIGA ; do
	NOME=$(echo $RIGA | awk -F ':' '{ print $1 }')
	read SECONDARIGA
	TELEFONO=$(echo $SECONDARIGA | awk -F ':' '{ print $2 }')
        echo $NOME $TELEFONO
done

# Posso sfruttare direttamente il word splitting della shell
# ma devo stare attento a non interferire con comandi 
# che si aspettano la presenza dello spazio in IFS
# (sebbene di default IFS sia vuota)

export  IFS=":"
cat "$1" | while read NOME INDIRIZZO ; do
	read DATA TELEFONO
	echo $NOME $TELEFONO
done

# più prudente, limita la modifica di IFS al solo 
# contesto di esecuzione dei comandi read

cat "$1" | while IFS=":" read NOME INDIRIZZO ; do
	IFS=":" read DATA TELEFONO
	echo $NOME $TELEFONO
done


	
