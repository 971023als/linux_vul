#!/bin/bash

. function.sh

BAR

CODE [U-09] /etc/hosts 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: /etc/hosts 파일의 소유자가 root이고, 권한이 600인 이하경우

[취약]: /etc/hosts 파일의 소유자가 root가 아니거나, 권한이 600 이상인 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  /etc/hosts  백업 파일 생성
cp /etc/hosts.bak /etc/hosts

cat $result

echo ; echo