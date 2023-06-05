#!/bin/bash

ARR[0]="zero";
ARR[1]="UNO";
ARR[2]="2";

echo "echo con !: ${!ARR[@]}";
echo "echo senza !: ${ARR[@]}";
echo "echo di valore a indice 0: ${ARR[0]}";
