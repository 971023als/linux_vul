#!/bin/bash

. function.sh

BAR

CODE [U-24] NFS 서비스 비활성화		

cat << EOF >> $result

[양호]: 불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있는 경우

[취약]: 불필요한 NFS 서비스 관련 데몬이 활성화 되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# Backup NFS configuration files
cp /etc/dfs/dfstab /etc/dfs/dfstab.bak
cp /etc/exports /etc/exports.bak

# Restore the NFS service
cp /etc/rc.d/rc2.d/_S60nfs /etc/rc.d/rc2.d/S60nfs

cat $result

echo ; echo
