#!/bin/bash
#
# dato come primo parametro un hostname, restituire il numero di processi rilevato su tale macchina


ssh -n $1 "ps haux | wc -l" 

# perché è prudente mettere "-n"?
