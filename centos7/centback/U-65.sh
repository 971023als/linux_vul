#!/bin/bash

 

. function.sh

 

BAR

CODE [U-65] at 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: at 접근제어 파일의 소유자가 root이고, 권한이 640 이하인 경우

[취약]: at 접근제어 파일의 소유자가 root가 아니거나, 권한이 640 이하가 아닌 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1 

#  백업 파일 생성
cp /usr/bin/at.bak /usr/bin/at
#  백업 파일 생성
cp /etc/at.deny.bak /etc/at.deny


cat $result

echo ; echo 