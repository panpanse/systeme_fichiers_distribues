#!/bin/bash

serverMasterIp=$1

# placement au bon endroit
cd /usr/src/mfs-1.6.20-2

# compilation avec les options qui vont bien
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/lib --with-default-user=mfs --with-default-group=mfs --disable-mfschunkserver --disable-mfsmount

make

make install

# "creation" des fichiers de conf
cd /etc
cp mfsmetalogger.cfg.dist mfsmetalogger.cfg

# ajout du serveur maitre dans /etc/hosts
echo "$serverMasterIp mfsmaster" >> /etc/hosts

# demarrage du serveur
/usr/sbin/mfsmetalogger start
