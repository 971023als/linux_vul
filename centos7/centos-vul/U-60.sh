#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1  
 

BAR

CODE [U-60] ssh 원격접속 허용

cat << EOF >> $result

[양호]: 원격 접속 시 SSH 프로토콜을 사용하는 경우

[취약]: 원격 접속 시 Telnet, FTP 등 안전하지 않은 프로토콜을 사용하는 경우

EOF

BAR

# ssh 바이너리가 있는지 확인하십시오
if command -v ssh > /dev/null 2>&1; then
  OK "SSH가 설치되었습니다."
else
  WARN "SSH가 설치되지 않았습니다."
fi

cat $result

echo ; echo 
