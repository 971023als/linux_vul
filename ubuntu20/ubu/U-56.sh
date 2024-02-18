#!/bin/bash

 

. function.sh

 

BAR

CODE [U-56] UMASK 설정 관리 

cat << EOF >> $result

[양호]: UMASK 값이 022 이하로 설정된 경우

[취약]: UMASK 값이 022 이하로 설정되지 않은 경우 

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

# /etc/profile에 UMASK 추가(존재하지 않는 경우)
if ! grep -q "UMASK=022" /etc/profile; then
  echo "umask 022" >> /etc/profile
  echo "export umask" >> /etc/profile
  INFO "UMASK가 /etc/profile에 추가되었습니다."
else
  OK "UMASK가 /etc/profile에 이미 있습니다."
fi

cat $result

echo ; echo 

 
