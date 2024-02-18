#!/bin/bash

. function.sh

BAR

CODE [U-34] DNS Zone Transfer 설정

cat << EOF >> $result

[양호]: DNS 서비스 미사용 또는, Zone Transfer를 허가된 사용자에게만 허용한 경우

[취약]: DNS 서비스를 사용하며 Zone Transfer를 모든 사용자에게 허용한 경우

EOF

BAR 

# named 서비스의 PID 찾기
PIDs=$(ps -ef | grep named | awk '{print $2}')

# named 서비스 중지
for PID in $PIDs; do
    kill -9 $PID
done

cat $result

echo ; echo