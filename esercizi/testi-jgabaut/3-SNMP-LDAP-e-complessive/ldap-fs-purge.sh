#!/bin/bash

function dn_to_path()
{
	FN=""
	echo $1 | sed -e 's/,dc=labammsis//' | sed -e 's/fn=//g' | sed -e 's/,/\n/g' | ( while read a
		do
		    FN="$a/$FN"
		done
		echo /$FN | sed -e 's/\/$//'
	)
}



ldapsearch -x -s sub -b "dc=labammsis" "(|(objectClass=dir)(objectClass=file))" | grep "^dn: " | cut -c5- | rev | sort -r | rev | while read name ; do
	# il dn è nella forma fn=filename,fn=to,fn=path,dc=labammsis
	# che rappresenta /path/to/filename

	# l'ordinamento rev / sort -r / rev garantisce che path lunghi 
	# vengano prima di path corti 
	# -->
	# nel caso rimuovo i nodi figli prima dei padri

	FILE=$(dn_to_path $name)
	test -e "$FILE" || echo "$name"

	# il ciclo emette i DN da eliminare
	# un'unica connessione autenticata al server li elimina
done | ldapdelete -D "cn=admin,dc=labammsis" -w "admin" -x 
