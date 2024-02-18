#!/bin/bash

 

. function.sh

 
 

BAR

CODE [U-54] Session Timeout 설정

cat << EOF >> $result

[양호]: Session Timeout이 600초(10분) 이하로 설정되어 있는 경우

[취약]: Session Timeout이 600초(10분) 이하로 설정되지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1


# /etc/profile에 TMOUT 추가(존재하지 않는 경우)
if ! grep -q "TMOUT=600" /etc/profile; then
  echo "TMOUT=600" >> /etc/profile
  echo "export TMOUT" >> /etc/profile
  INFO "/etc/profile에 TMOUT가 추가되었습니다."
else
  OK "TMOUT가 /etc/profile에 이미 있습니다."
fi





cat $result

echo ; echo
