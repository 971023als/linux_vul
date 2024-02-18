#!/bin/bash

. function.sh

BAR

CODE [U-05] root홈, 패스 디렉터리 권한 및 패스 설정

cat << EOF >> $result

[양호]: PATH 환경변수에 “.” 이 맨 앞이나 중간에 포함되지 않은 경우

[취약]: PATH 환경변수에 “.” 이 맨 앞이나 중간에 포함되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  /etc/profile  백업 파일 생성
cp /etc/profile.bak /etc/profile 
cp ~/.profile.bak ~/.profile

cat $result

echo ; echo