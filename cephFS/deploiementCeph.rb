#!/usr/bin/ruby -w
# encoding: utf-8

############################################

# File Name : deploiementCeph.rb

# Purpose :

# Creation Date : 11-03-2011

# Last Modified : jeu. 17 mars 2011 14:54:51 CET

# Created By : Helldar

############################################

# doit concorder avec la commande oarsub

if ARGV[0] != nil
	numberOfServers = ARGV[0].to_i	
	puts "Nb serveur : #{numberOfServers}\n"
else
	puts "Veuillez relancer le script avec les bons paramètres!\nUsage : <nombre de serveur>"
	exit
end

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
puts "Machines en cour de déploiement..."
`kadeploy3 -k -e squeeze-collective -u flevigne -f listOfNodes` # image collective

# configuration du serveur
serveur_1 = `head -1 listOfServers | cut -d "." -f1`.strip
ip_serveur = `ssh root@#{serveur_1}  ifconfig eth0 |grep inet\  | cut -d ":" -f2 |cut -d ' ' -f1`.strip

# génération du fichier de ceph.conf

`touch ceph.conf`
File.open("ceph.conf", 'w') do |file|
     file << "[global]
             pid file = /var/run/ceph/$name.pid
             debug ms = 1
             keyring = /etc/ceph/keyring.bin
[mon]
             mon data = /tmp/partage/mon$id
[mon0]
             host = #{serveur_1}
             mon addr = #{ip_serveur}:6789
[mds]
             debug mds = 1
             keyring = /etc/ceph/keyring.$name"
  if numberOfServers > 3
    1.upto(3) { |i|
      file << "
[mds#{i - 1}]"
      host = `sed -n #{i + 1}p listOfServers | cut -d '.' -f1`.strip
      puts "host #{i} : #{host}\n"
      file << "
			 #{host}"
    }
  else
    file << "[mds0]"
    host = `sed -n 2p listOfServers | cut -d '.' -f1`.strip
    file << "
			 #{host}" 
  end
  file << "
[osd]
			 sudo = true
			 osd data = /tmp/partage/osd$id
			 keyring = /etc/ceph/keyring.$name
			 debug osd = 1
			 debug filstore = 1
			 osd journal = /tmp/partage/osd$id/journal
			 osd journal size = 1000"
  1.upto(numberOfServers) { |i|
    file << "
[osd#{i - 1}]"
    host = `sed -n #{i}p listOfServers | cut -d '.' -f1`.strip
    file << "
			 #{host}"
  }
end

# copie du fichier ceph.conf vers le serveur
`scp ceph.conf root@#{serveur_1}:/etc/ceph`
puts "Envoyé!"

# génération du fichier keyring.bin
`ssh root@#{serveur_1} cauthtool --create-keyring -n client.admin --gen-key keyring.bin`
`ssh root@#{serveur_1} cauthtool -n client.admin --cap mds 'allow' --cap osd 'allow *' --cap mon 'allow rwx' keyring.bin`
`ssh root@#{serveur_1} mv keyring.bin /etc/ceph/`
puts "Keyring généré!"

# montage
`ssh root@#{serveur_1} mount -o remount,user_xattr /tmp`
1.upto(numberOfServers - 1) { |i|
  serveurs = `sed -n #{i + 1}p listOfServers | cut -d "." -f1`.strip
  `ssh root@#{serveurs} mount -o remount,user_xattr /tmp`
}
puts "Montage fait!"

# démarrage du serveur
`ssh root@#{serveur_1} mkcephfs -c /etc/ceph/ceph.conf --allhosts -v -k /etc/ceph/keyring.bin`
`ssh root@#{serveur_1} /etc/init.d/ceph -a start`
puts "Serveur ceph démarré!"

# configuration des clients
1.upto(`wc -l listOfClients`.to_i) { |i|
  clients = `sed -n #{i}p listOfClients | cut -d "." -f1`.strip
	`ssh root@#{clients} mkdir /ceph`
	`ssh root@#{clients} cfuse -m #{ip_serveur} /ceph`
}
puts "Clients montés!"
