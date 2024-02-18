#!/bin/bash


. function.sh

BAR

CODE [U-67] SNMP 서비스 Community String의 복잡성 설정

cat << EOF >> $result

[양호]: SNMP Community 이름이 public, private 이 아닌 경우

[취약]: SNMP Community 이름이 public, private 인 경우

EOF

BAR


TMP1=`SCRIPTNAME`.log

> $TMP1 

#  백업 파일 생성
INFO "66번에서 백업 파일이 생성되었습니다."

cat $result

echo ; echo 
