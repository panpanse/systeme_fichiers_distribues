#!/usr/bin/ruby -w
# encoding: utf-8

# reservation des noeuds (a lancer manuellement)
# oarsub -I -t deploy -l nodes=8,walltime=2 
# oarsub -I -t deploy -l nodes=8,walltime=2 -p "cluster='graphene'"

if ARGV[0] == nil
	puts "doit prendre en parametre le nombre de serveurs"
	exit(1)
end


# doit concorder avec la commande oarsub
numberOfServers = "#{ARGV[0]}".to_i

infiniband = 1 # 1 : active, 0 : non active (ne change rien pour l'instant)

# creation d'un fichier contenant la liste des noeuds reserves
`touch listOfNodes`
File.open("listOfNodes", 'w') do |file|
	file << `cat $OAR_FILE_NODES | sort -u`
end

# creation de deux fichiers contenant la liste des serveurs, et des clients
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

# deploiement des machines
puts "Machines en cours de deploiement..."
`kadeploy3 -k -e squeeze-collective -u flevigne -f listOfNodes` # image collective


# Creation d'un repertoire dans /tmp/sharedspace sur les serveurs
File.open("listOfServers", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`ssh root@#{machine} mkdir /tmp/sharedspace`
	end 
end

# Creation d'un repertoire dans /media/glusterfs sur les clients
File.open("listOfClients", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`ssh root@#{machine} mkdir /media/glusterfs`
	end 
end

masterServer = `head -n 1 listOfServers`.split.join("\n")

# generation des fichiers de conf, et envoie des fichiers de conf aux machines (serveurs et clients)
puts "Configuration des serveurs et des clients..."
`scp listOfServers root@#{masterServer}:`
`scp listOfClients root@#{masterServer}:`
`scp glusterfs-volgen.rb root@#{masterServer}:`
`ssh root@#{masterServer} ./glusterfs-volgen.rb`

# demarrage des serveurs
puts "Demarrage des serveurs..."
File.open("listOfServers", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`ssh root@#{machine} /etc/init.d/glusterfs-server start`
	end
end

# montage du repertoire par les clients
puts "Montage du repertoire par les clients..."
File.open("listOfClients", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`ssh root@#{machine} mount -t glusterfs /etc/glusterfs/glusterfs.vol /media/glusterfs`
	end
end

# resume des machines
puts "GlusterFS operationnel"
puts "\nMachines clients :"
puts `cat listOfClients`

puts "\nMachines serveurs :"
puts `cat listOfServers`

puts "\nServeur maitre : #{masterServer}"

# nettoyage
#`rm listOfNodes listOfClients listOfServers`
