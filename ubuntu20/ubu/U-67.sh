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


# 파일 정의
file="/etc/snmp/snmpd.conf"

# "get-community-name: public / set-commnunity-name : private"을 "get-community-name: min / set-commnunity-name: min"로 바꿉니다
sed -i 's/get-community-name: public/ set-community-name: private/g; s/get-community-name: min/ set-community-name: min/g' $file


cat $result

echo ; echo 
