#!/usr/bin/ruby -w
# encoding: utf-8

if "#{ARGV[0]}" == ""
	puts "Doit prendre en paramètre le nombre de clients participant au bench."
	exit(1)
end

clientsOfBench = "#{ARGV[0]}"

# chemin du fichier contenant la liste des clients
listOfClients = "/home/flevigne/glusterFs/listOfClients"

# chemin ou écrire les données du benchmark
whereToWrite = "/media/glusterfs"

# chemin du fichier contenant les résultats
outputRes = "./resOfBench"

# le client doit avoir dans /home/flevigne :
# - linux-2.6.37.tar.bz2 : noyau linux compressé
# - bigFile : un fichier de 3 Go

# fichier contenant la liste des clients participant au benchmark
`touch clientOfBench`
`head -#{clientsOfBench} #{listOfClients} > clientOfBench`

# si le fichier outputRes n'existe pas, on le crée.
if !File.exist?(outputRes)
	`touch #{outputRes}`
end

`echo "Benchmark sur #{clientsOfBench} clients" >> #{outputRes}`

numberOfClients = open("clientOfBench").read.count("\n").to_i

puts "Lancement du benchmarck sur #{numberOfClients} clients."

###################################
### ecriture de petits fichiers ###
###################################

puts "bench : ecriture de petits fichiers"

workFinished = 0
startOfBench = Time.now

# execution du sript pour tous les clients
File.open("clientOfBench", 'r') do |file|
	while line = file.gets
		fork do
			machine = line.split.join("\n")
			`scp writingSmallFiles.sh root@#{machine}:/root`
			`ssh root@#{machine}  ./writingSmallFiles.sh #{whereToWrite}`
			exit(0)
		end
	end 
end

# on attend que tous les clients aient fini leur travail
1.upto(numberOfClients) do
	pid = Process.wait
	workFinished += 1
	puts "Machine(s) ayant terminé leur travail : #{workFinished}"
end

endOfBench = Time.now
duration = endOfBench - startOfBench 

puts "Toute les machines ont terminé leur travail."

puts " --> Le benchmark \"ecriture petits fichiers\" a duré #{duration} secondes."

`echo "Ecriture petits fichiers : #{duration}" >> #{outputRes}`

###################################
#### ecriture de gros fichiers ####
###################################

puts "bench : ecriture de gros fichiers"

workFinished = 0
startOfBench = Time.now

# execution du sript pour tous les clients
File.open("clientOfBench", 'r') do |file|
	while line = file.gets
		fork do
			machine = line.split.join("\n")
			`scp writingBigFiles.sh root@#{machine}:/root`
			`ssh root@#{machine}  ./writingBigFiles.sh #{whereToWrite}`
			exit(0)
		end
	end 
end

# on attend que tous les clients aient fini leur travail
1.upto(numberOfClients) do
	pid = Process.wait
	workFinished += 1
	puts "Machine(s) ayant terminé leur travail : #{workFinished}"
end

endOfBench = Time.now
duration = endOfBench - startOfBench 

puts "Toute les machines ont terminé leur travail."

puts " --> Le benchmark \"ecriture de gros fichiers\" a duré #{duration} secondes."

`echo "Ecriture gros fichiers : #{duration}" >> #{outputRes}`

###################################
### lecture de petits fichiers ###
###################################

puts "bench : lecture de petits fichiers"

workFinished = 0
startOfBench = Time.now

# execution du sript pour tous les clients
File.open("clientOfBench", 'r') do |file|
	while line = file.gets
		fork do
			machine = line.split.join("\n")
			`scp readingSmallFiles.sh root@#{machine}:/root`
			`ssh root@#{machine}  ./readingSmallFiles.sh #{whereToWrite}`
			exit(0)
		end
	end 
end

# on attend que tous les clients aient fini leur travail
1.upto(numberOfClients) do
	pid = Process.wait
	workFinished += 1
	puts "Machine(s) ayant terminé leur travail : #{workFinished}"
end

endOfBench = Time.now
duration = endOfBench - startOfBench 

puts "Toute les machines ont terminé leur travail."

puts " --> Le benchmark \"lecture de petits fichiers\" a duré #{duration} secondes."

`echo "Lecture petits fichiers : #{duration}" >> #{outputRes}`

###################################
### lecture de gros fichiers ###
###################################

puts "bench : lecture de gros fichiers"

workFinished = 0
startOfBench = Time.now

# execution du sript pour tous les clients
File.open("clientOfBench", 'r') do |file|
	while line = file.gets
		fork do
			machine = line.split.join("\n")
			`scp readingBigFile.sh root@#{machine}:/root`
			`ssh root@#{machine} ./readingBigFile.sh #{whereToWrite}`
			exit(0)
		end
	end 
end

# on attend que tous les clients aient fini leur travail
1.upto(numberOfClients) do
    pid = Process.wait
	workFinished += 1
	puts "Machine(s) ayant terminé leur travail : #{workFinished}"
end

endOfBench = Time.now
duration = endOfBench - startOfBench 

puts "Toute les machines ont terminé leur travail."

puts " --> Le benchmark \"lecture de gros fichiers\" a duré #{duration} secondes."

`echo "Lecture gros fichiers : #{duration}\n" >> #{outputRes}`

# nettoyage du système de fichier distribue
oneClient = `head -1 clientOfBench`.strip
`ssh root@#{oneClient} rm -r #{whereToWrite}/*`
