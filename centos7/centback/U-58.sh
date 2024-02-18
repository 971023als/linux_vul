#!/bin/bash

. function.sh
 
BAR

CODE [U-58] 홈 디렉터리로 지정한 디렉터리의 존재 관리 

cat << EOF >> $result

[양호]: 홈 디렉터리가 존재하지 않는 계정이 발견되지 않는 경우

[취약]: 홈 디렉터리가 존재하지 않는 계정이 발견된 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

#  /etc/passwd  백업 파일 생성
INFO "4번에서 /etc/passwd 백업 파일이 생성되었습니다."

cat $result

echo ; echo

