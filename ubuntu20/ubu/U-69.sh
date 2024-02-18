#!/bin/bash

. function.sh

BAR

CODE [U-69] NFS 설정파일 접근권한

cat << EOF >> $result

[양호]: NFS 접근제어 설정파일의 소유자가 root 이고, 권한이 644 이하인 경우

[취약]: NFS 접근제어 설정파일의 소유자가 root 가 아니거나, 권한이 644 이하가 아닌 경우

EOF

BAR


TMP1=`SCRIPTNAME`.log

> $TMP1 

filename="/etc/exports"

chown root "$filename"
chmod 644 "$filename"

cat $result

echo ; echo 

