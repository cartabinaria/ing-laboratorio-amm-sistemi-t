#!/bin/bash

# /etc/passwd
#   -->
#
# dn: fn=etc,dc=labammsis
# ....
#
# dn: fn=passwd,fn=etc,dc=labammsis
# ...

function map() {
	# primo parametro: prefisso
	# secondo parametro: path da convertire
	DN="$1"
	# /etc/prova/ciao.txt --cut--> etc/prova/ciao.txt
	# --sed->
	# etc --> DN="fn=etc,dc=labammsis"
	# prova --> DN="fn=prova,fn=etc,dc=labammsis"
	# ciao.txt --> DN="fn=ciao.txt,fn=prova,fn=etc,dc=labammsis"
	echo $2 | cut -f2- -d/ | sed -e 's/\/$//' | sed -e 's/\//\n/g' | ( while read fn ; do 
	DN="fn=$fn,$DN"
	if test "$3" = "create" ; then
		echo dn: $DN
		echo objectClass: organization
		echo objectClass: dir
		echo fn: $fn
		echo o: labammsis
		echo 
	fi >> /tmp/header.ldif
 done ; echo $DN )
}

cat /dev/null > /tmp/header.ldif
PRE=$(map "dc=labammsis" $1 create)
cd "$1"

find | while read NOME ; do
	STAT=$(stat --format='%s %F' "$NOME")
	SIZE=$(echo $STAT | awk '{ print $1 }')
	TYPE=$(echo $STAT | awk '{ print $2 }')
	
	# produce il dn
	echo -n "dn: "
	map "$PRE" $NOME
	echo objectClass: organization
	if test "$TYPE" = "directory" ; then
		echo objectClass: dir
	else
		echo objectClass: file
		echo fs: $SIZE
	fi
	echo fn: $(basename $NOME)
	echo o: labammsis
	echo
done > /tmp/data.ldif

cat /tmp/header.ldif /tmp/data.ldif | ldapadd -c -x -D "cn=admin,dc=labammsis" -w admin
