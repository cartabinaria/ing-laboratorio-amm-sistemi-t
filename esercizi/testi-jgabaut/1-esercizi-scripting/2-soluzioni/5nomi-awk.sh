#!/bin/bash

cat /etc/passwd | awk -F ':' '{ print $3,$1 }' | sort -nr | head -$1 | cut -f2 -d" "

