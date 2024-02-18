#!/bin/bash

. function.sh

BAR

CODE [U-60] ssh 원격접속 허용

cat << EOF >> $result

[양호]: 원격 접속 시 SSH 프로토콜을 사용하는 경우

[취약]: 원격 접속 시 Telnet, FTP 등 안전하지 않은 프로토콜을 사용하는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1  

#  백업 파일 생성
cp /etc/telnet.bak /etc/telnet

#  백업 파일 생성  
cp /etc/ftp.bak /etc/ftp

#  백업 파일 생성
cp /etc/ssh.bak /etc/ssh


cat $result

echo ; echo 
