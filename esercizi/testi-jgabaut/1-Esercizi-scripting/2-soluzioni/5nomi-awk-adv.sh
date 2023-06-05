#!/bin/bash
# mostra gli N utenti con id immediatamente successivi rispetto a quello dell'utente passato come primo parametro
uid=$(egrep "^$1:" /etc/passwd | awk -F ':' '{ print $3 }')


# con funzioni avanzate di awk
cat /etc/passwd | awk -F ':' -v app=$uid '$3 >= app { print $3,$1 }' | sort -n | head -$2 | cut -f2 -d" "

