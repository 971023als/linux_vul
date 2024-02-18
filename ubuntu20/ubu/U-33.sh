#!/bin/bash

. function.sh

BAR

CODE [U-33]  DNS 보안 버전 패치 '확인 필요'

cat << EOF >> $result
[양호]: DNS 서비스를 사용하지 않거나 주기적으로 패치를 관리하고 있는 경우

[취약]: DNS 서비스를 사용하며 주기적으로 패치를 관리하고 있지 않는 경우
EOF

BAR
 
# DNS 서비스의 PID 찾기
PIDs=$(ps -ef | grep named | awk '{print $2}')

# DNS 서비스 중지
for PID in $PIDs; do
    kill -9 $PID
done

cat $result

echo ; echo