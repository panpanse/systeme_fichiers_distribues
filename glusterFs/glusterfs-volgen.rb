#!/usr/bin/env ruby
# encoding: utf-8

# volgen : commande de generation des fichiers de conf
volgen = "glusterfs-volgen --name mystore"

# pour utiliser l'infini bande : (ne marche pas, ne pas utiliser pour le moment)
# volgen = "glusterfs-volgen --name mystore -t ib-verbs"

# construction de la commande volgen
File.open("listOfServers", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		volgen += " #{machine}:/tmp/sharedspace"
	end 
end

# génération des fichiers de conf
`#{volgen}`

# envoie des fichier de conf aux serveurs
File.open("listOfServers", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		configFile = machine + "-mystore-export.vol"
		`scp #{configFile} root@#{machine}:/etc/glusterfs/glusterfsd.vol`
	end
end

# envoie des fichier de conf aux clients
File.open("listOfClients", 'r') do |file|
	while line = file.gets
		machine = line.split.join("\n")
		`scp mystore-tcp.vol root@#{machine}:/etc/glusterfs/glusterfs.vol`
	end
end
