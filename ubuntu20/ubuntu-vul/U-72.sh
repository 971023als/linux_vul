#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-72] 정책에 따른 시스템 로깅 설정

cat << EOF >> $result

[양호]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있는 경우

[취약]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1 

filename="/etc/rsyslog.conf"

if [ ! -e "$filename" ]; then
  WARN "$filename 가 존재하지 않습니다"
fi

expected_content=(
  "*.info;mail.none;authpriv.none;cron.none /var/log/messages"
  "authpriv.* /var/log/secure"
  "mail.* /var/log/maillog"
  "cron.* /var/log/cron"
  "*.alert /dev/console"
  "*.emerg *"
)

match=0
for content in "${expected_content[@]}"; do
  if grep -q "$content" "$filename"; then
    match=$((match + 1))
  fi
done

if [ "$match" -eq "${#expected_content[@]}" ]; then
  OK "$filename의 내용이 정확합니다."
else
  WARN "$filename의 내용이 잘못되었습니다."
fi


cat $result

echo ; echo 

 
