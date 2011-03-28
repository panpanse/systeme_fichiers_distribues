#!/usr/bin/ruby -w
# encoding: utf-8


if ARGV[0] == nil || ARGV[1] == nil || ARGV[2] == nil
	puts "Usage correcte :"
	puts "param1 : nombe de clients participant au bench"
	puts "param2 : fichier de sortie"
	puts "param3 : url de la liste des clients"
	puts "param4 : lieu d'ecriture du bench"
	exit(1)
end

$clientsOfBench = "#{ARGV[0]}"

# chemin du fichier contenant la liste des clients
#listOfClients = "/home/flevigne/glusterFs/listOfClients"
listOfClients = "#{ARGV[2]}"

# chemin ou ecrire les donnees du benchmark
#whereToWrite = "/media/glusterfs"
whereToWrite = "#{ARGV[3]}"

# chemin du fichier contenant les resultats
$outputRes = "#{ARGV[1]}"

# le client doit avoir dans /home/flevigne :
# - linux-2.6.37.tar.bz2 : noyau linux compresse
# - bigFile : un fichier de 3 Go

# fichier contenant la liste des clients participant au benchmark
`touch clientOfBench`
`head -#{$clientsOfBench} #{listOfClients} > clientOfBench`

# si le fichier $outputRes n'existe pas, on le cree.
if !File.exist?($outputRes)
	`touch #{$outputRes}`
end

`echo "\nBenchmark sur #{$clientsOfBench} clients" >> #{$outputRes}`

$numberOfClients = open("clientOfBench").read.count("\n").to_i
puts "nombre de clients : #{$numberOfClients}"

puts "Lancement du benchmarck sur #{$numberOfClients} clients."


# lance un travail
# parametres :
# - name : nom du travail (str)
# - work : chemin du script de travail (str)
# - whereToWrite : chemin ou ecrire les donnees du benchmark (str)
# - size : taille (en Mo) du/des fichier(s) a ecrire/lire (float)
def startBench(name, work, whereToWrite, size)
	puts "bench : #{name} en cours..."

	totalSize = size.to_i * $clientsOfBench.to_i
	workFinished = 0
	startOfBench = Time.now

	# execution du sript pour tous les clients
	File.open("clientOfBench", 'r') do |file|
		while line = file.gets
			fork do
				machine = line.split.join("\n")
				`scp #{work} root@#{machine}:/root`
				`ssh root@#{machine} ./#{work} #{whereToWrite}`
				exit(0)
			end
		end 
	end

	# on attend que tous les clients aient fini leur travail
	1.upto($numberOfClients) do
		pid = Process.wait
		workFinished += 1
		puts "Machine(s) ayant termine leur travail : #{workFinished}"
	end

	endOfBench = Time.now
	duration = endOfBench - startOfBench 

	puts "Toute les machines ont termine leur travail."

	puts " --> Le benchmark \"#{name}\" a dure #{duration} secondes. (debit : #{totalSize / duration} Mo/s)"

	`echo "#{name} : #{duration} sec : #{totalSize / duration} Mo/s" >> #{$outputRes}`
end


# lancement du benchmark
startBench("ecriture de petits fichiers", "writingSmallFiles.sh", whereToWrite, 479)
startBench("ecriture de gros fichiers", "writingBigFiles.sh", whereToWrite, 3076)
startBench("lecture de petits fichiers", "readingSmallFiles.sh", whereToWrite, 479)
startBench("lecture de gros fichiers", "readingBigFile.sh", whereToWrite, 3076)

# nettoyage du systeme de fichier distribue (necessaire pour enchainer les benchmark)
puts "Nettoyage de l'espace de travail..."
oneClient = `head -1 clientOfBench`.strip
`ssh root@#{oneClient} rm -r #{whereToWrite}/*`

puts "\nBenchmark termine"
