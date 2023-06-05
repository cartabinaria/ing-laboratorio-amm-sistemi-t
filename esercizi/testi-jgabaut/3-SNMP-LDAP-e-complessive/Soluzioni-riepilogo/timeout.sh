#!/bin/bash
#
# per rispettare la precisione richiesta è sufficente mettere questo script in cron ogni minuto
# * * * * * /path/to/timeout.sh


# formato di iptables -vnL
# 1274  1854933 ACCEPT     tcp  --  *      bond1   212.239.43.38        137.204.57.118      tcp spt:1081
#
# prendo direttamente solo le righe che non hanno il primo campo a zero
# 
iptables -Z -vnxL FORWARD | egrep '^[[:space:]]*[123456789]+' | while read pkts bytes target proto opts intin intout srcip destip proto2 ports ; do
	DPT=$(echo $ports | cut -f2 -d:)
	atrm $(cat /tmp/timer_$srcip_$destip_$DPT)
	echo "/root/openclose.sh D $srcip $destip $DPT" | at now + 5 minutes 2>&1 | grep ^job | awk '{ print $2 }' > /tmp/timer_$srcip_$destip_$DPT
done



