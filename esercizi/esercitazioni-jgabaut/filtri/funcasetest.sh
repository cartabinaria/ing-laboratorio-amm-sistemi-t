#!/bin/bash
# $1 nome comando, deve essere ls | rm | touch
# $2 = nome file
# $3 = facoltativo, numero 1-9
# $# = n. di argomenti

function waitfile() {
	if test $# -ge 2 ; then #controllo se ci sono gli argomenti obbligatori
		if test $1 = ls -o $1 = rm -o $1 = touch ; then #controllo se comando valido
			case "$3" in #controllo valore terzo argomento
			force) $1 $2 ; exit 0 ;; #esecuzione immediata e uscita, come valuto risultato comando?
			[1-9]) N="$3" ;;
			*) N=10;;
			esac
			while [ "$N" -gt 0 ] ; do #ciclo sul valore di N
				if test -a "$2" ; then #controllo se file esiste
					$1 $2 ; exit 0 ; #esecuzione e uscita, come valuto risultato comando?
				else echo "file $2 "'non esiste, wait 1 sec...'; sleep 1; #attesa
				fi
				let N--;
			done #fine ciclo
			echo 'timeout'; exit 3 #uscita per timeout
		else echo "$1" ' is not a valid command, use ls or rm or touch' ; exit 2 #uscita per comando non valido
		fi
	else echo 'missing mandatory arguments. usage: waitfile <ls|rm|touch> filename [force|N]' ; exit 1 #uscita per mancanza di argomenti
	fi

}

waitfile "$1" "$2" "$3" 
