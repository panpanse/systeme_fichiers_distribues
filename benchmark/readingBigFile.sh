#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

cd "$whereToWrite/$nameOfMachine"

# lecture des gros fichiers
cat bigFile1 > /dev/nul
cat bigFile2 > /dev/nul
cat bigFile3 > /dev/nul
