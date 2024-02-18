#!/bin/bash

. function.sh

BAR

CODE [U-18] 접속 IP 및 포트 제한

cat << EOF >> $result

[양호]: 접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한을 설정한 경우

[취약]: 접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한을 설정하지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
cp /etc/hosts.allow.bak /etc/hosts.allow
cp /etc/hosts.deny.bak /etc/hosts.deny

cat $result

echo ; echo