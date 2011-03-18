#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

# creation du repertoire de travail de la machine
mkdir "$whereToWrite/$nameOfMachine"

# decompression dans ce repertoire
cd "$whereToWrite/$nameOfMachine"
tar -xf /home/flevigne/linux-2.6.37.tar.bz2
