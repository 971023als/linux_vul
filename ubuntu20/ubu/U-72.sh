#!/bin/bash

. function.sh

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
  INFO "$filename 가 존재하지 않습니다"
fi

expected_content=(
  "*.info;mail.none;authpriv.none;cron.none /var/log/messages"
  "authpriv.* /var/log/secure"
  "mail.* /var/log/maillog"
  "cron.* /var/log/cron"
  "*.alert /dev/console"
  "*.emerg *"
)

for content in "${expected_content[@]}"; do
  if ! grep -q "$content" "$filename"; then
    echo "$content" >> "$filename"
  fi
done

INFO "콘텐츠가 $filename 에 추가되었습니다."

cat $result

echo ; echo 

 
