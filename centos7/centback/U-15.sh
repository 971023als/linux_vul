#!/bin/bash

. function.sh

BAR

CODE [U-15] world writable 파일 점검 @@ 조치 후 웹 서비스 장애  @@

cat << EOF >> $result

[양호]: 시스템 중요 파일에 world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인하고 있는 경우

[취약]: 시스템 중요 파일에 world writable 파일이 존재하나 해당 설정 이유를 확인하고 있지 않는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  권한 관련 파일
INFO "권한 관련 파일이라 조치 15번 진행하시면 됩니다."

cat $result

echo ; echo