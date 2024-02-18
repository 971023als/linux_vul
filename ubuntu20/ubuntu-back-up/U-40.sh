#!/bin/bash

. function.sh

BAR

CODE [U-40] 웹서비스 파일 업로드 및 다운로드 제한

cat << EOF >> $result

[양호]: 파일 업로드 및 다운로드를 제한한 경우

[취약]: 파일 업로드 및 다운로드를 제한하지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
INFO "35번에서 /etc/apache2/apache2.conf 백업 파일이 생성되었습니다."


cat $result

echo ; echo