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

# gluster n serveurs
cd ~/glusterFS
echo "./deploiementGluster.rb $nb_serveur"
./deploiementGluster.rb $nb_serveur

# benchmark sur 1 client
cd ~/benchmark
./benchmark.rb 1 "~/resOfBench/gluster$nb_serveur" ~/glusterFS/listOfClients /media/glusterfs
# benchmark sur 5 clients
./benchmark.rb 5 "~/resOfBench/gluster$nb_serveur" ~/glusterFS/listOfClients /media/glusterfs
# benchmark sur 20 clients 
./benchmark.rb 20 "~/resOfBench/gluster$nb_serveur" ~/glusterFS/listOfClients /media/glusterfs
# benchmark sur 50 clients 
./benchmark.rb 50 "~/resOfBench/gluster$nb_serveur" ~/glusterFS/listOfClients /media/glusterfs
