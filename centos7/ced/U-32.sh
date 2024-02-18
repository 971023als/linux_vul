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

INFO "이 부분은 백업 파일 관련한 항목이 아닙니다"

#---------------------------------------------------

# Sendmail 서비스 재시작
sudo service sendmail restart

# Sendmail이 실행 중인지 확인
PID=$(ps -ef | grep sendmail | awk '{print $2}')
if [ -z "$PID" ]; then
  INFO "메일 보내기 서비스를 시작할 수 없습니다."
else
  OK "Sendmail 서비스가 PID: $PID 로 시작되었습니다."
fi

cat $result

echo ; echo

