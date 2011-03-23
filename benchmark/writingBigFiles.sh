#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

# on copie les gros fichiers au lieu voulu
cp /home/flevigne/bigFile1 "$whereToWrite/$nameOfMachine"
cp /home/flevigne/bigFile2 "$whereToWrite/$nameOfMachine"
cp /home/flevigne/bigFile3 "$whereToWrite/$nameOfMachine"
