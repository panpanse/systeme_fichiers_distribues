#!/bin/bash

# la réservation doit être faite à la main :
# oarsub -I -t deploy -l nodes=10,walltime=2 
# oarsub -I -t deploy -l nodes=10,walltime=2 -p "cluster='graphene'"

# gluster 5 serveurs
cd ../glusterFs
./deploiementGluster.rb 5

# benchmark sur 2 clients 
cd ../benchmark
./benchmark.rb 2 ../resOfBench/gluster5 ../glusterFs/listOfClients /media/glusterfs
# benchmark sur 3 clients 
./benchmark.rb 3 ../resOfBench/gluster5 ../glusterFs/listOfClients /media/glusterfs

# mooseFs 5 serveurs
cd ../mooseFs
./deploiementMoose.rb 5

## benchmark sur 2 clients 
cd ../benchmark
./benchmark.rb 2 ../resOfBench/moose5 ../mooseFs/listOfClients /media/mfs
# benchmark sur 3 clients 
./benchmark.rb 3 ../resOfBench/moose5 ../mooseFs/listOfClients /media/mfs
