#!/bin/bash

. function.sh

BAR

CODE [U-30] Sendmail 버전 점검

cat << EOF >> $result

[양호]: Sendmail 버전이 최신버전인 경우 

[취약]: Sendmail 버전이 최신버전이 아닌 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

#  서비스 관련 파일
INFO "서비스 관련 파일이라 조치 30번 진행하시면 됩니다."

cat $result

echo ; echo
 
