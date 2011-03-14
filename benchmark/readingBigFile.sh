#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

cd "$whereToWrite/$nameOfMachine"

# lecture du gros fichier
cat bigFile > /dev/nul
