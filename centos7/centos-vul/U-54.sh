#!/bin/bash

 

. function.sh

 

TMP1=`SCRIPTNAME`.log

> $TMP1

 

BAR

CODE [U-54] Session Timeout 설정

cat << EOF >> $result

[양호]: Session Timeout이 600초(10분) 이하로 설정되어 있는 경우

[취약]: Session Timeout이 600초(10분) 이하로 설정되지 않은 경우

EOF

BAR

# /etc/profile에서 TMOUT가 600으로 설정되어 있는지 확인합니다
if grep -q "TMOUT=600" /etc/profile; then
  OK "/etc/profile에서 TMOUT가 600으로 설정됨"
else
  WARN "/etc/profile에서 TMOUT가 600으로 설정되지 않음"
fi



cat $result

echo ; echo
