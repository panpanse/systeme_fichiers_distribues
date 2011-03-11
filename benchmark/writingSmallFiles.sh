#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

# creation du repertoire de travail de la machine
mkdir "$whereToWrite/$nameOfMachine"

# decompression
cd /home/flevigne
tar -xf "linux-2.6.37.tar.bz2"

# copie dans le rep partage
cp -r /home/flevigne/linux-2.6.37 "$whereToWrite/$nameOfMachine"

#cp /home/flevigne/linux-2.6.37.tar.bz2 "$whereToWrite/$nameOfMachine"
#cd "$whereToWrite/$nameOfMachine"

# on la décompresse
#tar -xf "linux-2.6.37.tar.bz2"
