#!/bin/bash

. function.sh

BAR

CODE [U-50] 관리자 그룹에 최소한의 계정 포함

cat << EOF >> $result

양호: 관리자 그룹에 불필요한 계정이 등록되어 있지 않은 경우

취약: 관리자 그룹에 불필요한 계정이 등록되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

#  /etc/passwd  백업 파일 생성
INFO "4번에서 /etc/passwd 백업 파일이 생성되었습니다."

cat $result

echo ; echo
