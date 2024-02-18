#!/bin/bash

. function.sh

TMP1=`SCRIPTNAME`.log

>$TMP1 


BAR

CODE [U-11] /etc/rsyslog.conf 파일 소유자 및 권한 설정 

cat << EOF >> $result 

[양호]: /etc/rsyslog.conf 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하인 경우

[취약]: /etc/rsyslog.conf 파일의 소유자가 root(또는 bin, sys)가 아니거나, 권한이  640 이하가 아닌 경우

EOF

BAR


# 파일 소유권 확인
if [ -e "/etc/rsyslog.conf" ]; then
  file_owner=$(stat -c %U /etc/rsyslog.conf)
if [[ "$file_owner" != "root" && "$file_owner" != "bin" && "$file_owner" != "sys" ]]; then
  WARN " /etc/rsyslog.conf가 루트(또는 bin, sys)에 의해 소유되지 않습니다."
fi

# 파일 권한 확인
file_perms=$(stat -c %a /etc/rsyslog.conf)
dec_perms=$(printf "%d" $file_perms)

if [ $dec_perms -lt 640 ]; then
      WARN "/etc/rsyslog.conf에 대한 사용 권한은 안전하지 않습니다"
  else
      OK "/etc/rsyslog.conf에 대한 사용 권한은 안전합니다"
  fi

else
  OK "/etc/rsyslog.conf 존재하지 않음"
fi

cat $result

echo ; echo

 



 
