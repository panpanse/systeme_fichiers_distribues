#!/usr/bin/ruby -w
# encoding: utf-8

# chemin du fichier contenant la liste des clients
listOfClients = "/home/flevigne/glusterFs/listOfClients"

# chemin ou écrire les données du benchmark
whereToWrite = "/media/glusterfs"

# le client doit avoir dans /home/flevigne :
# - linux-2.6.37.tar.bz2 : noyau linux compressé
# - bigFile : un fichier de 3 Go

numberOfClients = open("#{listOfClients}").read.count("\n").to_i

puts "Lancement du benchmarck sur #{numberOfClients} clients."

###################################
### ecriture de petits fichiers ###
###################################

puts "bench : ecriture de petits fichiers"

workFinished = 0
startOfBench = Time.now

# execution du sript pour tous les clients
File.open("#{listOfClients}", 'r') do |file|
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

###################################
#### ecriture de gros fichiers ####
###################################

puts "bench : ecriture de gros fichiers"

workFinished = 0
startOfBench = Time.now

# execution du sript pour tous les clients
File.open("#{listOfClients}", 'r') do |file|
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

###################################
### lecture de petits fichiers ###
###################################

puts "bench : lecture de petits fichiers"

workFinished = 0
startOfBench = Time.now

# execution du sript pour tous les clients
File.open("#{listOfClients}", 'r') do |file|
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

###################################
### lecture de gros fichiers ###
###################################

puts "bench : lecture de gros fichiers"

workFinished = 0
startOfBench = Time.now

# execution du sript pour tous les clients
File.open("#{listOfClients}", 'r') do |file|
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
