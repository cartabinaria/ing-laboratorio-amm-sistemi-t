#!/bin/sh
#$1 directory in cui cercare i file

if ! [[ -d "$1" ]] ; then
	echo "$1 non è una directory valida" ; exit 1 ;
fi

DIR="$1"

function searchDirectory() {

	for FILE in "$DIR"/*; do

		if [[ -f "$FILE" ]] ; then {
			FLAG=0;
			LASTACCESS=$(stat --format='%X' "$FILE")
			LASTMOD=$(stat --format='%Y' "$FILE")
			WEEKSECONDS=$(( 7*24*60*60  ))
	
			if [[ $(( $(date +%s) - $LASTACCESS )) -lt $WEEKSECONDS || $(( $(date +%s) - $LASTMOD )) < $WEEKSECONDS ]] ; then { #controlla che ultimo accesso/modifica sia avvenuto meno di un settimana fa 
				FLAG=1;			
			} ; 
			fi

			if [[ $(stat --format='%a' "$FILE" | cut -c4) ]] ; then { #controlla che permessi in ottale abbiano 4 caratteri, cioé che siano settati bit speciali
				FLAG=1;
			} ;
			fi
			
			SIZE=$(stat --format='%s' "$FILE")
			if [[ $(file "$FILE" | grep "text") && $SIZE -le 100000 && grep -q "DOC" "$FILE" ]] ; then { #controlla che il file sia di tipo text, di dimensione inferiore a 100k, contenga string DOC
				FLAG=1;
			} ;
			fi

		} elif [[ -d "$FILE" ]] ; then {
			searchDirectory("$FILE");
		} else echo "File $FILE non valido" ;
		fi

		if [[ $FLAG ]] ; then {
			
		}
		fi	
	done
}

TIME=$(date +"%Y%m%d_%H%M")
tar -cf "backup_$TIME.tar"
