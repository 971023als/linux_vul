#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1

 

BAR

CODE [U-03] 계정 잠금 임계값 설정

cat << EOF >> $result

[양호]: 계정 잠금 임계값이 10회 이하의 값으로 설정되어 있는 경우

[취약]: 계정 잠금 임계값이 설정되어 있지 않거나, 10회 이하의 값으로 설정되지 않은 경우

EOF

BAR

if grep -q "auth required pam_tally2.so deny=10 unlock_time=900" /etc/pam.d/system-auth; then
  OK "auth required pam_required pam_required2.so deny=10 unlock_time=900 존재."
else
  WARN "auth required pam_required pam_required2.so deny=10 unlock_time=900 없음."
fi


cat $result

echo ; echo
