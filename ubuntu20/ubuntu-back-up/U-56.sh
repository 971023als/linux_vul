#!/bin/bash

. function.sh

BAR

CODE [U-56] UMASK 설정 관리 

cat << EOF >> $result

[양호]: UMASK 값이 022 이하로 설정된 경우

[취약]: UMASK 값이 022 이하로 설정되지 않은 경우 

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

#  백업 파일 생성
INFO "5번에서 백업 파일이 생성되었습니다."

cat $result

echo ; echo 

 
