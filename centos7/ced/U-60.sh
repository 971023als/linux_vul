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
#/etc/telnet
#/etc/ftp
#/etc/ssh



INFO "이 부분은 백업 파일 관련한 항목이 아닙니다"

#---------------------------------------------------


# Stop ssh service
sudo service ssh stop


cat $result

echo ; echo 
