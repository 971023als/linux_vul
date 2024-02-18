#!/bin/bash

 

. function.sh


TMP1=`SCRIPTNAME`.log

> $TMP1 

BAR

CODE [U-56] UMASK 설정 관리 

cat << EOF >> $result

[양호]: UMASK 값이 022 이하로 설정된 경우

[취약]: UMASK 값이 022 이하로 설정되지 않은 경우 

EOF

BAR

# /etc/profile에서 UMASK가 022로 설정되어 있는지 확인합니다
if grep -q "umask 022" /etc/profile; then
  OK "umask가 /etc/profile에서 022로 설정됨"
else
  WARN "umask가 /etc/profile에서 022로 설정되지 않음"
fi

# /etc/profile에서  export umask 로 설정되어 있는지 확인합니다
if grep -q "export umask" /etc/profile; then
  OK "/etc/profile에서 export umask로 설정됨"
else
  WARN "/etc/profile에서 export umask로 설정되지 않음"
fi


cat $result

echo ; echo 

 
