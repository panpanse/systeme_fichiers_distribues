#!/bin/bash

serverMasterIp=$1

# placement au bon endroit
cd /usr/src/mfs-1.6.20-2

# compilation avec les options qui vont bien
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/lib --with-default-user=mfs --with-default-group=mfs --disable-mfsmaster --disable-mfschunkserver

make

make install

# ajout du serveur maitre dans /etc/hosts
echo "$serverMasterIp mfsmaster" >> /etc/hosts

# rep de montage
mkdir /media/mfs
# montage
/usr/bin/mfsmount /media/mfs -H mfsmaster
