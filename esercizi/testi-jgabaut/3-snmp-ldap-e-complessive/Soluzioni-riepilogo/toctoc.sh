#!/bin/bash
# check parametri
ssh "$1" "echo $2 $3 > "'/tmp/$(echo $SSH_CLIENT | cut -f1 -d" ") ; sleep 60'
