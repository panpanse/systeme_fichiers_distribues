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


# gluster 5 serveurs
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


# NFS
cd ~/NFS
echo "./deploiementNFS.rb"
./deploiementNFS.rb

# benchmark sur 1 client
cd ~/benchmark
./benchmark.rb 1 "~/resOfBench/gluster$nb_serveur" ~/NFS/listOfNodes /tmp/partage
# benchmark sur 5 clients 
./benchmark.rb 5 "~/resOfBench/gluster$nb_serveur" ~/NFS/listOfNodes /tmp/partage
# benchmark sur 20 clients 
./benchmark.rb 20 "~/resOfBench/gluster$nb_serveur" ~/NFS/listOfNodes /tmp/partage
# benchmark sur 50 clients 
./benchmark.rb 50 "~/resOfBench/gluster$nb_serveur" ~/NFS/listOfNodes /tmp/partage


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
