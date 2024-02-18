#!/bin/bash

. function.sh

BAR

CODE [U-12] /etc/services 파일 소유자 및 권한 설정		

cat << EOF >> $result

[양호]: etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하
인 경우

[취약]: etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하
인 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  /etc/services  백업 파일 생성
cp /etc/services.bak /etc/services

cat $result

echo ; echo
