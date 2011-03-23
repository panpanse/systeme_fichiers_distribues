#!/bin/bash

# la réservation doit être faite à la main :
# oarsub -I -t deploy -l nodes=10,walltime=2 
# oarsub -I -t deploy -l nodes=10,walltime=2 -p "cluster='graphene'"

# NFS
cd ~/NFS
echo "./deploiementNFS.rb"
./deploiementNFS.rb

# benchmark sur 1 client
cd ~/benchmark
./benchmark.rb 1 "~/resOfBench/gluster" ~/NFS/listOfNodes /tmp/partage
# benchmark sur 5 clients 
./benchmark.rb 5 "~/resOfBench/gluster" ~/NFS/listOfNodes /tmp/partage
# benchmark sur 20 clients 
./benchmark.rb 20 "~/resOfBench/gluster" ~/NFS/listOfNodes /tmp/partage
# benchmark sur 50 clients 
./benchmark.rb 50 "~/resOfBench/gluster" ~/NFS/listOfNodes /tmp/partage
