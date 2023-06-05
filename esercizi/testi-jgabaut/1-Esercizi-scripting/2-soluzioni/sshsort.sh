#!/bin/bash

# dato il file testo sulla macchina locale, farlo ordinare alla macchina con meno processi tra quelle del file lista e mettere il risultato nel file testo.ord (della macchina locale)


cat testo | ssh `./sshload.sh` sort > testo.ord

# perché sarebbe più prudente questa variante? 

cat testo | ssh `./sshload.sh < /dev/null` sort > testo.ord
