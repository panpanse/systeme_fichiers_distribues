#!/bin/bash

# la réservation doit être faite à la main :
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

## benchmark sur 2 clients 
cd ~/benchmark
./benchmark.rb 2 "~/resOfBench/moose$nbserveur" ~/mooseFs/listOfClients /media/mfs
# benchmark sur 3 clients 
./benchmark.rb 3 "~/resOfBench/moose$nbserveur" ~/mooseFs/listOfClients /media/mfs
## benchmark sur 5 clients 
cd ~/benchmark
./benchmark.rb 5 "~/resOfBench/moose$nbserveur" ~/mooseFs/listOfClients /media/mfs
# benchmark sur 10 clients 
./benchmark.rb 10 "~/resOfBench/moose$nbserveur" ~/mooseFs/listOfClients /media/mfs

# ceph 5 serveurs
cd ~/cephFS
./deploiementGluster.rb $nbserveur

# benchmark sur 2 clients 
cd ~/benchmark
./benchmark.rb 2 "~/resOfBench/ceph$nbserveur" ~/cephFS/listOfClients /ceph
# benchmark sur 3 clients 
./benchmark.rb 3 "~/resOfBench/ceph$nbserveur" ~/cephFS/listOfClients /ceph
# benchmark sur 5 clients 
cd ~/benchmark
./benchmark.rb 5 "~/resOfBench/ceph$nbserveur" ~/cephFS/listOfClients /ceph
# benchmark sur 10 clients 
./benchmark.rb 10 "~/resOfBench/ceph$nbserveur" ~/cephFS/listOfClients /ceph

# gluster 5 serveurs
cd ~/glusterFS
./deploiementGluster.rb $nbserveur

# benchmark sur 2 clients 
cd ~/benchmark
./benchmark.rb 2 "~/resOfBench/gluster$nbserveur" ~/glusterFS/listOfClients /media/glusterfs
# benchmark sur 3 clients 
./benchmark.rb 3 "~/resOfBench/gluster$nbserveur" ~/glusterFS/listOfClients /media/glusterfs
# benchmark sur 5 clients 
cd ~/benchmark
./benchmark.rb 5 "~/resOfBench/gluster$nbserveur" ~/glusterFS/listOfClients /media/glusterfs
# benchmark sur 10 clients 
./benchmark.rb 10 "~/resOfBench/gluster$nbserveur" ~/glusterFS/listOfClients /media/glusterfs
