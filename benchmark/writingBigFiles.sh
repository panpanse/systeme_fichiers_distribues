#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

# on copie le gros fichier au lieu voulu
cp /home/flevigne/bigFile "$whereToWrite/$nameOfMachine"
