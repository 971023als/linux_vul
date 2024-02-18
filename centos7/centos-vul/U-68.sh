#!/bin/bash

 

. function.sh


TMP1=`SCRIPTNAME`.log

> $TMP1   

BAR

CODE [U-68] 로그온 시 경고 메시지 제공

cat << EOF >> $result

[양호]: 서버 및 Telnet 서비스에 로그온 메시지가 설정되어 있는 경우

[취약]: 서버 및 Telnet 서비스에 로그온 메시지가 설정되어 있지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1 

files=("/etc/motd" "/etc/issue.net" "/etc/vsftpd/vsftpd.conf" "/etc/mail/sendmail.cf" "/etc/named.conf")

for file in "${files[@]}"; do
  if [ ! -e "$file" ]; then
    INFO "$file이 존재하지 않습니다."
  else
    OK "$file이 존재합니다."
  fi
done


cat $result

echo ; echo

 
