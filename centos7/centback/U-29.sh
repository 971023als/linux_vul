#!/bin/bash

. function.sh

BAR

CODE [U-29] tftp, talk 서비스 비활성화		

cat << EOF >> $result

[양호]: tftp, talk, ntalk 서비스가 비활성화 되어 있는 경우

[취약]: tftp, talk, ntalk 서비스가 활성화 되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
cp /etc/xinetd.d/tftp.bak /etc/xinetd.d/tftp
cp /etc/xinetd.d/talk.bak /etc/xinetd.d/talk
cp /etc/xinetd.d/ntalk.bak /etc/xinetd.d/ntalk

cat $result

echo ; echo
