#!/bin/bash

. function.sh

BAR

CODE [U-08] /etc/shadow 파일 소유자 및 권한 설정		

cat << EOF >> $result

[양호]: /etc/shadow 파일의 소유자가 root이고, 권한이 400 이하인 경우

[취약]: /etc/shadow 파일의 소유자가 root가 아니거나, 권한이 400 이하가 아닌 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  /etc/shadow  백업 파일 생성
INFO "4번에서 /etc/shadow 백업 파일이 생성되었습니다."

cat $result

echo ; echo
