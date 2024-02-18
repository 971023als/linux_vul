#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1  

BAR

CODE [U-33]  DNS 보안 버전 패치 '확인 필요'

cat << EOF >> $result

[양호]: DNS 서비스를 사용하지 않거나 주기적으로 패치를 관리하고 있는 경우

[취약]: DNS 서비스를 사용하며 주기적으로 패치를 관리하고 있지 않는 경우


EOF

BAR

# 명명된 프로세스가 실행 중인지 확인하십시오
results=$(ps -ef | grep named | grep -v grep)

# 결과 변수가 비어 있으면 명명된 프로세스가 실행되고 있지 않습니다
if [ -z "$results" ]; then
  OK "DNS 서비스가 실행되고 있지 않습니다."
else
  WARN "DNS 서비스가 실행 중입니다."
fi


cat $result

echo ; echo