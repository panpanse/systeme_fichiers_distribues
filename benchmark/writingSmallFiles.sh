#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

# creation du repertoire de travail de la machine
mkdir "$whereToWrite/$nameOfMachine"

# copie dans le rep partage
cp -r /home/flevigne/linux-2.6.37 "$whereToWrite/$nameOfMachine"
