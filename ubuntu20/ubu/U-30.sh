#!/bin/bash

. function.sh

BAR

CODE [U-30] Sendmail 버전 점검

cat << EOF >> $result

[양호]: Sendmail 버전이 최신버전인 경우 

[취약]: Sendmail 버전이 최신버전이 아닌 경우

EOF

BAR

# Sendmail 서비스의 PID 찾기
PIDs=$(ps -ef | grep sendmail | awk '{print $2}')

# Sendmail 서비스 중지
for PID in $PIDs; do
    kill -9 $PID
done

cat $result

echo ; echo
 
