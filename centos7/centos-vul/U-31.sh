#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1
 

BAR

CODE [U-31] 스팸 메일 릴레이 제한

cat << EOF >> $result

[양호]: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있는 경우

[취약]: SMTP 서비스를 사용하며 릴레이 제한이 설정되어 있지 않은 경우

EOF

BAR


# Sendmail 서비스가 실행 중인지 확인합니다
sendmail_status=$(ps -ef | grep sendmail | grep -v "grep")

if [ "$sendmail_status" == "active" ]; then
  WARN "Sendmail 서비스가 실행 중입니다."
else
  OK "Sendmail 서비스가 실행되고 있지 않습니다."
fi


cat $result

echo ; echo
 
