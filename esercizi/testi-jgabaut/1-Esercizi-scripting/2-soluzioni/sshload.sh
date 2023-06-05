#!/bin/bash
#
# trovare la macchina con meno processi in esecuzione tra quelle elencate nel file "lista"

# for host in 172.20.2.2 172.20.2.3 ; do

for host in `cat lista` ; do
	echo `./sshnum.sh $host` $host
done | sort -n | head -1 | awk '{ print $2 }' 


# cat lista | while read host ; do
# 	ssh $host "comandoremoto" < /dev/null
# ..

