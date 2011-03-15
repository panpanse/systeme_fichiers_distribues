#!/usr/bin/ruby -w
# encoding: utf-8

# réservation des noeuds (a lancer manuellement)
# oarsub -I -t deploy -l nodes=8,walltime=2 
# oarsub -I -t deploy -l nodes=8,walltime=2 -p "cluster='graphene'"

# doit concorder avec la commande oarsub
numberOfClients = 5
numberOfServers = 3

infiniband = 1 # 1 : activé, 0 : non activé (ne change rien pour l'instant)

# création d'un fichier contenant la liste des noeuds réservés
`touch listOfNodes`
File.open("listOfNodes", 'w') do |file|
	file << `cat $OAR_FILE_NODES | sort -u`
end

# création de deux fichiers contenant la liste des serveurs, et des clients
`touch listOfClients listOfServers`
serverWrited = 0
File.open("listOfNodes", 'r') do |node|
	File.open("listOfServers", 'w') do |server|
		File.open("listOfClients", 'w') do |client|
			while line = node.gets
				if serverWrited < numberOfServers
					server << line
					serverWrited += 1
				else
					client << line
				end
			end 
		end
	end
end

# déploiement des machines
puts "Machines en cours de déploiement..."
#`kadeploy3 -k -a ../images/mysqueezegluster-x64-base.env -f listOfNodes` # image perso
`kadeploy3 -k -e squeeze-collective -u flevigne -f listOfNodes` # image collective


# Envoie d'un script de création d'un répertoire dans /tmp/sharedspace sur les serveurs
File.open("listOfServers", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`ssh root@#{machine} < createFolders.sh`
	end 
end

# Envoie d'un script de création d'un répertoire dans /media/glusterfs sur les clients
File.open("listOfClients", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`ssh root@#{machine} < createMountDirectory.sh`
	end 
end

masterServer = `head -n 1 listOfServers`.split.join("\n")

# génération des fichiers de conf, et envoie des fichiers de conf aux machines (serveurs et clients)
puts "Configuration des serveurs et des clients..."
`scp listOfServers root@#{masterServer}:`
`scp listOfClients root@#{masterServer}:`
`scp glusterfs-volgen.rb root@#{masterServer}:`
`ssh root@#{masterServer} ./glusterfs-volgen.rb`
#`ssh root@#{masterServer} < execScript/ex-glusterfs-volgen.sh`

# démarrage des serveurs
puts "Démarrage des serveurs..."
File.open("listOfServers", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`ssh root@#{machine} < startGluster.sh`
	end
end

# montage du répertoire par les clients
puts "Montage du répertoire par les clients..."
File.open("listOfClients", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`ssh root@#{machine} < mountFs.sh`
	end
end

# résumé des machines
puts "GlusterFS opérationnel"
puts "\nMachines clients :"
puts `cat listOfClients`

puts "\nMachines serveurs :"
puts `cat listOfServers`

puts "\nServeur maitre : #{masterServer}"

# nettoyage
#`rm listOfNodes listOfClients listOfServers`
