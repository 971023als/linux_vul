#!/bin/bash

. function.sh

BAR

CODE [U-10] /etc/inetd.conf 파일 소유자 및 권한 설정		

cat << EOF >> $result

[양호]: /etc/inetd.conf 파일의 소유자가 root이고, 권한이 600인 경우

[취약]: /etc/inetd.conf 파일의 소유자가 root가 아니거나, 권한이 600이 아닌 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  /etc/inetd.conf  백업 파일 생성
cp /etc/xinetd.conf.bak /etc/xinetd.conf

cat $result

echo ; echo
