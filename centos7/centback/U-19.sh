#!/bin/bash

. function.sh

BAR

CODE [U-19] finger 서비스 비활성화		

cat << EOF >> $result

[양호]: Finger 서비스가 비활성화 되어 있는 경우

[취약]: Finger 서비스가 활성화 되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
cp /etc/xinetd.d/finger.bak /etc/xinetd.d/finger

cat $result

echo ; echo
