#!/bin/bash

. function.sh

BAR

CODE [U-51] 계정이 존재하지 않는 GID 금지

cat << EOF >> $result

양호: 존재하지 않는 계정에 GID 설정을 금지한 경우

취약: 존재하지 않은 계정에 GID 설정이 되어있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

#    백업 파일 생성
cp /etc/group.bak /etc/group


cat $result

echo ; echo
