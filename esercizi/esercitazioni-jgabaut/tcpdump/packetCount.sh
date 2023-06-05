#!/bin/bash

#realizzare uno script che resti in ascolto del traffico di rete con tcpdump e memorizzi il totale dei byte ricevuti da ogni IP sorgente

# controlla che il processo stia eseguendo con effective user id 0, ovvero root, altrimenti esce
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

# 13:45:58.886130 lo    In  IP 127.0.0.1.42505 > 127.0.0.1.514: SYSLOG local1.info, length: 126
# TIME INT DIR PROTO SRC ARROW DST RESTO

tcpdump -nl -i any 2>/dev/null | ( while read L ; do
	IPSORG=$(echo $L | awk -F "IP " '{ print $2 }' | cut -f1 -d' ' | cut -f1-4 -d'.')
	SIZE=$(echo $L | rev | cut -f1 -d' ' | rev )
done
)

