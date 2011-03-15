#!/bin/bash

# placement au bon endroit
cd /usr/src/mfs-1.6.20-2

# compilation avec les options qui vont bien
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/lib --with-default-user=mfs --with-default-group=mfs --disable-mfschunkserver --disable-mfsmount

make

make install

# "creation" des fichiers de conf
cd /etc
cp mfsmaster.cfg.dist mfsmaster.cfg
cp mfsmetalogger.cfg.dist mfsmetalogger.cfg
cp mfsexports.cfg.dist mfsexports.cfg

cd /var/lib/mfs
cp metadata.mfs.empty metadata.mfs

# ajout du serveur maitre dans /etc/hosts
ipserver=`hostname -i`
echo "$ipserver mfsmaster" >> /etc/hosts

# demarrage du serveur
/usr/sbin/mfsmaster start
