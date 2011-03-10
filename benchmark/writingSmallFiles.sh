#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

# on copie l'archive au lieu voulu
mkdir "$whereToWrite/$nameOfMachine"
cp /home/flevigne/linux-2.6.37.tar.bz2 "$whereToWrite/$nameOfMachine"
cd "$whereToWrite/$nameOfMachine"

# on la décompresse
tar -xf "linux-2.6.37.tar.bz2"
