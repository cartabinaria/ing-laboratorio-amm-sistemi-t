#!/bin/bash
#                                       log_user.sh
# individua l'utente responsabile
# lo scrive nel log excess 

# ipotesi: root di Router puo' accedere a root di ogni Client senza password

# invocato con SIP DIP SP DP

# ssh $1 "netstat -nte | egrep '$1:$3.*$2:$4' | awk '{ print \$7 }'" | logger -p local1.info

#### ragionare attentamente sul quoting! ####

ssh $1 "ss -tpn | egrep '$1:$3.*$2:$4' | awk -F 'pid=' '{ print \$2 }' | cut -f1 -d, | xargs ps hu | awk '{ print \$1 }'" | logger -p local1.info

# snmpwalk -v 1 -c public $1 .1.3.6.1.4.1.8072 | grep loguser | grep nsExtendOutLine | egrep "$1:$3.*$2:$4" | awk -F 'pid=' '{ print $2 }' | cut -f1 -d, | xargs ps hu | awk '{ print $1 }' | logger -p local1.info
# ps va eseguito sul client!! come?


# ESTENSIONE: considerare tutti i pid non solo il primo di ss

