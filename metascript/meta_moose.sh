#!/bin/bash

# la reservation doit etre faite a la main :
# oarsub -I -t deploy -l nodes=10,walltime=2 
# oarsub -I -t deploy -l nodes=10,walltime=2 -p "cluster='graphene'"

if [ -z $1 ]
then
    echo -e "Usage : <nombre de serveurs>"
    exit 1
fi

nb_serveur=$1

# mooseFs 5 serveurs
cd ~/mooseFs
./deploiementMoose.rb $nb_serveur

# benchmark sur 2 clients 
cd ~/benchmark
#echo "./benchmark.rb 2 \"~/resOfBench/moose$nb_serveur\" ~/mooseFs/listOfClients /media/mfs"
./benchmark.rb 1 "~/resOfBench/moose$nb_serveur" ~/mooseFs/listOfClients /media/mfs
# benchmark sur 5 clients 
./benchmark.rb 5 "~/resOfBench/moose$nb_serveur" ~/mooseFs/listOfClients /media/mfs
# benchmark sur 20 clients 
./benchmark.rb 20 "~/resOfBench/moose$nb_serveur" ~/mooseFs/listOfClients /media/mfs
# benchmark sur 50 clients 
./benchmark.rb 50 "~/resOfBench/moose$nb_serveur" ~/mooseFs/listOfClients /media/mfs
