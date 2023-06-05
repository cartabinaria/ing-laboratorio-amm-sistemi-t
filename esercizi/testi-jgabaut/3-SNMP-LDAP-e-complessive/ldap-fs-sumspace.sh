#!/bin/bash
#
# versione semplice ma inefficiente:
#
#ldapsearch -x -s sub -b "dc=labammsis" "objectClass=dir" | grep "^dn: " | cut -c5- | while read dirname ; do
#	SIZE=0
#	ldapsearch -x -b "$dirname" -s sub "objectClass=file" | grep "^fs: " | cut -c5- | ( while read dim ; do
#		SIZE=$[ $SIZE + $dim ]
#	done
#	echo -e "dn: $dirname\nfs: $SIZE" | ldapmodify -x -D "cn=admin,dc=labammsis" -w admin
#	)	
#done


# versione ricorsiva
export TOTAL=0
export BASE=${1:-"dc=labammsis"}
# come dire:
# if test "$1" then BASE=$1 else BASE="dc=labammsis"

# esploro il singolo livello dell'albero sotto $BASE
# filtrando per sicurezza in base all'objectClass

ldapsearch -x -s one -b "$BASE" '(|(objectClass=file)(objectClass=dir))' | grep "^dn: " | cut -c5- | (
        while read name ; do
		# estraggo i due attributi utili dalla entry
		# il sort -r mi garantisce che si mostri prima objectClass che esiste sempre
		# poi eventualmente fs che c'è solo per i file

		VALORI=`ldapsearch -x -s base -b "$name" | egrep -i "^(objectClass|fs): " | sort -r | awk '{ print $2 }'`
                CLS=`echo $VALORI | awk '{ print $1 }'`
                DIM=`echo $VALORI | awk '{ print $2 }'`

                if test "$CLS" = "dir" ; then
                        if test "$DIM" = "" || test "$DIM" -eq 0 ; then
				# se è una dir non esplorata in precedenza
				# invoco questo stesso script passando il suo DN come parametro
				# --> partirà un'esplorazione ricorsiva del sottoalbero 
				# e restituirà la dimensione totale

                                DIM=`$0 "$name"`
                        fi
                fi

		# giunto qui, DIM è:
		# o la dimensione di un file ("if test ..." era falso)
		# o la dimensione di una subdirectory calcolata per invocazione ricorsiva
		# comunque, la accumulo agli altri contributi di questo livello di entry

                TOTAL=$[ $TOTAL + $DIM ]
        done

	# aggiorno la entry corrispondente alla dir base passata originariamente come parametro
        echo -e "dn: $BASE\nchangetype: modify\nreplace: fs\nfs: $TOTAL" | ldapmodify -x -D "cn=admin,dc=labammsis" -w admin >&2

	# emetto la dimensione a beneficio di chi mi ha invocato (vedi la riga DIM=`$0 "$name"`)
        echo "$TOTAL"
)


