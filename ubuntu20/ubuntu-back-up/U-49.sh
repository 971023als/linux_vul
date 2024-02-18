#!/bin/bash

 

. function.sh

BAR

CODE [U-49] 불필요한 계정 제거

cat << EOF >> $result

[양호]: 불필요한 계정이 존재하지 않는 경우

[취약]: 불필요한 계정이 존재하는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

#  /etc/passwd  백업 파일 생성
INFO "4번에서 /etc/passwd 백업 파일이 생성되었습니다."

 
cat $result

echo ; echo
