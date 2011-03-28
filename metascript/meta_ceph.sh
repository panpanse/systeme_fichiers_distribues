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

# ceph 5 serveurs
cd ~/cephFS
./deploiementCeph.rb $nb_serveur

# benchmark sur 1 client
cd ~/benchmark
./benchmark.rb 1 "~/resOfBench/ceph$nb_serveur" ~/cephFS/listOfClients /ceph
# benchmark sur 5 clients 
./benchmark.rb 5 "~/resOfBench/ceph$nb_serveur" ~/cephFS/listOfClients /ceph
# benchmark sur 20 clients 
./benchmark.rb 20 "~/resOfBench/ceph$nb_serveur" ~/cephFS/listOfClients /ceph
# benchmark sur 50 clients 
./benchmark.rb 50 "~/resOfBench/ceph$nb_serveur" ~/cephFS/listOfClients /ceph
