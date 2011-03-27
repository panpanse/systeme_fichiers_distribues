#!/usr/bin/ruby -w
# encoding: utf-8

############################################

# File Name : deploiementNFS.rb

# Creation Date : 17-03-2011

# Last Modified : dim. 27 mars 2011 22:15:59 CEST

# Created By : Helldar

############################################

`cat $OAR_FILE_NODES | sort -u > listOfNodes`

# Déploiement des machines
#puts "Machines en cour de déploiement...\n"
#`kadeploy3 -k -e squeeze-collective -u flevigne -f listOfNodes # image collective`

serveur = `head -1 listOfNodes`.strip
puts "Le serveur : #{serveur}!\n"
# Suppression du serveur de la liste
`sed -i 1d listOfNodes`

puts "Configuration du serveur...\n"
`scp exports root@#{serveur}:/etc/`
`ssh root@#{serveur} /etc/init.d/nfs-kernel-server restart`

puts "Configuration des clients...\n"
line = `wc -l listOfNodes | cut -d ' ' -f1`.strip.to_i
puts "Il y a #{line} nodes" 
1.upto(line) { |i| clients = `sed -n #{i}p listOfNodes | cut -d "." -f1`.strip
	`ssh root@#{clients} mkdir /tmp/partage`
	`ssh root@#{clients} mount -t nfs4 #{serveur}:/ /tmp/partage` }
