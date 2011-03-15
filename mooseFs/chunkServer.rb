#!/bin/bin/ruby -w

serverMasterIp = "#{ARGV[0]}"
numberOfChunk = "#{ARGV[1]}"
numOfChunk = "#{ARGV[2]}"

# placement au bon endroit
`cd /usr/src/mfs-1.6.20-2`

# compilation avec les options qui vont bien
`./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/lib --with-default-user=mfs --with-default-group=mfs --disable-mfsmaster`

`make`

`make install`

# "creation" des fichiers de conf
`cd /etc`
`cp mfschunkserver.cfg.dist mfschunkserver.cfg`
`cp mfshdd.cfg.dist mfshdd.cfg`

# conf fichier /etc/mfshdd.cfg
`mkdir /tmp/mfschunks#{numOfChunk}`
`chown -R mfs:mfs /tmp/mfschunks#{numOfChunk}`

numberOfChunk.times do |i|
	numChunk = i + 1
	`echo "/tmp/mfschunks#{numChunk}" >> /etc/mfshdd.cfg`
end

# ajout du serveur maitre dans /etc/hosts
`echo "$serverMasterIp mfsmaster" >> /etc/hosts`

# demarrage du serveur
`/usr/sbin/mfschunkserver start`
