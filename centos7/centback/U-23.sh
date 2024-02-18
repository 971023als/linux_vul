#!/bin/bash

. function.sh

BAR

CODE [U-23] DoS 공격에 취약한 서비스 비활성화		

cat << EOF >> $result

[양호]: 사용하지 않는 DoS 공격에 취약한 서비스가 비활성화 된 경우

[취약]: 사용하지 않는 DoS 공격에 취약한 서비스가 활성화 된 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
cp /etc/xinetd.d/echo.bak /etc/xinetd.d/echo
cp /etc/xinetd.d/discard.bak /etc/xinetd.d/discard
cp /etc/xinetd.d/daytime.bak /etc/xinetd.d/daytime
cp /etc/xinetd.d/chargen.bak /etc/xinetd.d/chargen


cat $result

echo ; echo
