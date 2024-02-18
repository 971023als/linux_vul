#!/bin/bash

. function.sh

BAR

CODE [U-54] Session Timeout 설정

cat << EOF >> $result

[양호]: Session Timeout이 600초(10분) 이하로 설정되어 있는 경우

[취약]: Session Timeout이 600초(10분) 이하로 설정되지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

#  /etc/profile  백업 파일 생성
INFO "5번에서 /etc/profile 백업 파일이 생성되었습니다."


cat $result

echo ; echo
