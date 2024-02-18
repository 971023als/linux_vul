#!/bin/bash

 

. function.sh
  

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
message="시스템에 오신 것을 환영합니다. 이 시스템은 인증된 용도로만 사용됩니다."

for file in "${files[@]}"; do
  if [ ! -e "$file" ]; then
    INFO "$file 이 없습니다. 건너뛰기."
  else
    echo "$message" > "$file"
    OK "로그온 메시지가 $file 로 설정되었습니다."
  fi
done

cat $result

echo ; echo

 
