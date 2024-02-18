#!/bin/bash

. function.sh

BAR

CODE [U-32] 일반사용자의 Sendmail 실행 방지		

cat << EOF >> $result

[양호]: SMTP 서비스 미사용 또는, 일반 사용자의 Sendmail 실행 방지가 설정된
경우

[취약]: SMTP 서비스 사용 및 일반 사용자의 Sendmail 실행 방지가 설정되어 
있지 않은 경우

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

