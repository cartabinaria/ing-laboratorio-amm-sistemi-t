#!/bin/bash
cat /etc/passwd | cut -f1,3 -d: --output-delimiter=" " | while read USERNAME USERID
do 
        echo $USERID $USERNAME
done | sort -nr | head -$1 | cut -f2 -d" "



