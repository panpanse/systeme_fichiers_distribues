#!/usr/bin/ruby -w

# reservation des noeuds (a lancer manuellement)
# oarsub -I -t deploy -l nodes=9,walltime=2 
# oarsub -I -t deploy -l nodes=9,walltime=2 -p "cluster='graphene'"

if ARGV[0] == nil
	puts "doit prendre en parametre le nombre de serveurs (3 min)"
	exit(1)
end

# doit concorder avec la commande oarsub
numberOfClients = 5 # inutile : prend les machines restantes en clients
numberOfServers = "#{ARGV[0]}".to_i # 3 serveurs minimum


# MooseFS et infinibande ?

# creation d'un fichier contenant la liste des noeuds reserves
`touch listOfNodes`
`cat $OAR_File_NODES`
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
`kadeploy3 -e squeeze-collective -u flevigne -f listOfNodes` # image collective

masterServer = `head -1 listOfServers`.strip # 1ere ligne du fichier
`sed -i 1d listOfServers` # supression de la 1ere ligne
metaloggerServer = `head -1 listOfServers`.strip
`sed -i 1d listOfServers`

masterServerIp = `ssh root@#{masterServer} hostname -i`.strip

# configuration du serveur maitre
puts "\nConfiguration du serveur maitre..."
`scp masterServer.sh root@#{masterServer}:/root`
`ssh root@#{masterServer} ./masterServer.sh`

# configuration du serveur de metadonnees
puts "\nConfiguration du serveur de metadonnees..."
`scp metaloggerServer.sh root@#{metaloggerServer}:/root`
`ssh root@#{metaloggerServer} ./metaloggerServer.sh #{masterServerIp}`

# configuration des chunks
puts "\nConfigurations des serveurs chunk..."
numberOfChunk = open("listOfServers").read.count("\n").to_i # numberOfChunk inutile ?

puts "Nombre de Chunk : #{numberOfChunk}"

# configuration des chunks
chunkConfiguration = 1
File.open("listOfServers", 'r') do |file|
	while line = file.gets
		machine = line.strip
		`scp chunkServer.rb root@#{machine}:/root`
		#`ssh root@#{machine} ./chunkServer.sh #{masterServerIp} #{numberOfChunk}`
		`ssh root@#{machine} ./chunkServer.rb #{masterServerIp} #{numberOfChunk} #{chunkConfiguration}`
		chunkConfiguration += 1
	end
end

# demarrage des chunks
puts "\nDemarrage des serveurs chunks"
File.open("listOfServers", 'r') do |file|
	while line = file.gets
		machine = line.strip
		`ssh root@#{machine} /usr/sbin/mfschunkserver start`
	end
end

puts "\nConfigurations des clients..."
# configuration des clients
File.open("listOfClients", 'r') do |file|
	while line = file.gets
		machine = line.strip
		`scp client.sh root@#{machine}:/root`
		`ssh root@#{machine} ./client.sh #{masterServerIp}`
	end
end

# resume
puts "\nmaster server :"
puts "#{masterServer} : #{masterServerIp}"

puts "\nmetalloger server :"
puts "#{metaloggerServer}"

puts "\nchunk servers :"
puts `cat listOfServers`

puts "\nMachines clients :"
puts `cat listOfClients`
