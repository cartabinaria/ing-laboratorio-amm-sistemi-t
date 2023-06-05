#!/bin/bash

NCOPIES=4
NUMERIC_REGEX='^[0-9]+$'

while getopts "n:" OPTION ; do
	case $OPTION in
		# n) if ! [[ $OPTARG =~ $NUMERIC_REGEX ]] ; then
		n) if ! echo "$OPTARG" | egrep -q "$NUMERIC_REGEX" ; then
				echo "-n deve essere seguito da un numero" >&2
				exit 1
		   else
				NCOPIES="$OPTARG"
		   fi
		;;
		?) echo "Uso: $0 [-n numero] filename" >&2
			exit 2
		;;
	esac
done

shift $(($OPTIND - 1))

if test $# -ne 1 -o ! -f "$1" 
then
	echo "specificare esattamente un nome di file" >&2
	exit 3
fi

LOGFILE=$1
NCOPIES=$(( $NCOPIES - 1 ))

# sposta $FNAME.9 in $FNAME.10 sovrascrivendolo
# sposta $FNAME.8 in $FNAME.9 eccetera
# alla fine non esistera' piu' $FNAME.1
for i in $(seq $NCOPIES -1 1) ; do
		test -f $LOGFILE.$i && mv $LOGFILE.$i $LOGFILE.$(( $i + 1 ))
done

# puo essere cp per i test della prima versione
cp $LOGFILE $LOGFILE.1

exit 0


