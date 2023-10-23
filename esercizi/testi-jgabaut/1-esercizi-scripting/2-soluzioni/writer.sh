#!/bin/bash
# realizzare uno script che scrive continuamente in un file "output", 
# al ritmo di qualche KB al secondo 

# note: 
# introduciamo il comando dd, la variabile RANDOM della shell
#
# riprendiamo il fatto che un builtin può innescare un intero 
# sottoprocesso di cui ridirigere gli stream


while sleep 1; do
		dd if=/dev/zero bs=1k count=$(( $(echo $RANDOM | rev | cut -c1) + 1 ))
done > output
