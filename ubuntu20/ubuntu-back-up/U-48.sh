#!/bin/bash

 
. function.sh

BAR

CODE [U-48] 패스워드 최소 사용기간 설정

cat << EOF >> $result

[양호]: 패스워드 최소 사용기간이 1일(1주)로 설정되어 있는 경우

[취약]: 패스워드 최소 사용기간이 설정되어 있지 않는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

#  백업 파일 생성
INFO "2번에서 /etc/login.defs 백업 파일이 생성되었습니다."


cat $result

echo ; echo
