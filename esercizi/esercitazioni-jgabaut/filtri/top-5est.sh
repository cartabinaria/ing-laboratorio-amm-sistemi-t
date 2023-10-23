#!/bin/bash
# nessun parametro atteso

ls -R 2>/dev/null | rev | egrep '^[[:alnum:]]+\.' | cut -f1 -d. | rev | sort | uniq -c | sort -nr| head -5 | less
