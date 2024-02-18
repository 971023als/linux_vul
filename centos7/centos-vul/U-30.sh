#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1
 
 

BAR

CODE [U-30] Sendmail 버전 점검

cat << EOF >> $result

[양호]: Sendmail 버전이 최신버전인 경우 

[취약]: Sendmail 버전이 최신버전이 아닌 경우

EOF

BAR

# Sendmail 서비스가 실행 중인지 확인합니다
sendmail_status=$(ps -ef | grep sendmail | grep -v "grep")

if [ "$sendmail_status" == "active" ]; then
  WARN "Sendmail 서비스가 실행 중입니다."
else
  OK "메일 보내기 서비스가 실행되고 있지 않습니다."
fi



cat $result

echo ; echo
 
