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

# 포트 22(SSH)에서 192.168.0.1로부터의 연결 허용
echo "sshd: 192.168.0.1" >> /etc/hosts.allow

# 포트 22(SSH)의 다른 모든 IP 주소에서 연결 거부
echo "sshd: ALL" >> /etc/hosts.deny

cat $result

echo ; echo