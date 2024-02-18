#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

>$TMP1

BAR

CODE [U-10] /etc/xinetd.conf 파일 소유자 및 권한 설정 

cat << EOF >> $result

[양호]: /etc/inetd.conf 파일의 소유자가 root이고, 권한이 600인 경우

[취약]: /etc/inetd.conf 파일의 소유자가 root가 아니거나, 권한이 600이 아닌 경우

EOF

BAR

# 파일이 있는지 확인하십시오
if [ ! -f /etc/xinetd.conf ]; then
  OK "/etc/xinetd.conf 파일이 없습니다"
else
  # 파일 소유권 확인
  file_owner=$(stat -c %U /etc/xinetd.conf)
  if [ "$file_owner" != "root" ]; then
    WARN " /etc/xinetd.conf가 루트에 의해 소유되지 않음"
  else
    # 파일의 사용 권한 확인
    file_perms=$(stat -c %a /etc/xinetd.conf)
    if [ "$file_perms" -lt 600 ]; then
      WARN " /etc/xinetd.conf에 권한이 600 초과입니다"
    else
      # 스크립트가 이 지점에 도달하면 소유권 및 사용 권한이 올바른 것입니다
      OK "/etc/xinetd.conf에 권한은 600 이하 입니다."
    fi
  fi
fi

cat $result

echo ; echo
 
