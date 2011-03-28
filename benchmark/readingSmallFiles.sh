#!/bin/bash

whereToWrite=$1

nameOfMachine=`uname -n`

cd "$whereToWrite/$nameOfMachine"

# lecture des fichiers du noyau linux (compression (donc lecture) redirigevers /dev/nul)
tar -cf /dev/null linux-2.6.37
