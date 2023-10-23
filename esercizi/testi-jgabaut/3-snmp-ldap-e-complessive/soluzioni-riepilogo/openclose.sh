#!/bin/bash
# 
# apre o chiude il firewall
#
CMD=$1
shift
iptables -$CMD FORWARD -p tcp -s $1 -d $2 --dport $3 -j ACCEPT
iptables -$CMD FORWARD -p udp -s $1 -d $2 --dport $3 -j ACCEPT
iptables -$CMD FORWARD -m state -p tcp -d $1 -s $2 --sport $3 --state ESTABLISHED -j ACCEPT
iptables -$CMD FORWARD -m state -p udp -d $1 -s $2 --sport $3 --state ESTABLISHED -j ACCEPT
iptables -t nat -$CMD POSTROUTING -p tcp -s $1 -d $2 --dport $3 -j SNAT --to-source 10.9.9.254
iptables -t nat -$CMD POSTROUTING -p udp -s $1 -d $2 --dport $3 -j SNAT --to-source 10.9.9.254

if test "$CMD" = "D" ; then
	if ldapsearch -h localhost -x -b "indirizzo=$1,dc=labammsis" -s base ; then
		# l'entry per il client esiste, verifico se esiste quella per il server al di sotto e nel caso leggo il numero di connessioni registrate finora
		COUNT=$(ldapsearch -LLL -h localhost -x -b "indirizzo=$2,indirizzo=$1,dc=labammsis" -s base contatore | grep ^contatore: | awk '{ print $2 }')
		if test "$COUNT" ; then
			echo "dn: indirizzo=$2,indirizzo=$1,dc=labammsis" > /tmp/ldif.$$
			echo "changetype: modify" >> /tmp/ldif.$$
			echo "replace: contatore" >> /tmp/ldif.$$
			echo "contatore: $[ $COUNT + 1]" >> /tmp/ldif.$$
			echo >> /tmp/ldif.$$
		else
			echo "dn: indirizzo=$2,indirizzo=$1,dc=labammsis" > /tmp/ldif.$$
			echo "objectClass: server" >> /tmp/ldif.$$
			echo "indirizzo: $2" >> /tmp/ldif.$$
			echo "contatore: 1" >> /tmp/ldif.$$
			echo >> /tmp/ldif.$$
		fi
	else
		# l'entry per il client non esiste (a maggior ragione non esisterà quella per il server)
		echo "dn: indirizzo=$1,dc=labammsis" > /tmp/ldif.$$
		echo "objectClass: client" >> /tmp/ldif.$$
		echo "indirizzo: $1" >> /tmp/ldif.$$
		echo >> /tmp/ldif.$$
		echo "dn: indirizzo=$2,indirizzo=$1,dc=labammsis" >> /tmp/ldif.$$
		echo "objectClass: server" >> /tmp/ldif.$$
		echo "indirizzo: $2" >> /tmp/ldif.$$
		echo "contatore: 1" >> /tmp/ldif.$$
		echo >> /tmp/ldif.$$
	fi
	ldapadd -x -D "cn=admin,dc=labammsis" -w admin -f /tmp/ldif.$$
	rm -f /tmp/ldif.$$
fi
