#!/bin/bash

. function.sh

BAR

CODE [U-21] r 계열 서비스 비활성화		

cat << EOF >> $result

[양호]: 불필요한 r 계열 서비스가 비활성화 되어 있는 경우

[취약]: 불필요한 r 계열 서비스가 활성화 되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
cp /etc/xinetd.d/rlogin.bak /etc/xinetd.d/rlogin
cp /etc/xinetd.d/rsh.bak /etc/xinetd.d/rsh
cp /etc/xinetd.d/rexec.bak /etc/xinetd.d/rexec

cat $result

echo ; echo
