#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1

 

BAR

CODE [U-48] 패스워드 최소 사용기간 설정

cat << EOF >> $result

[양호]: 패스워드 최소 사용기간이 1일(1주)로 설정되어 있는 경우

[취약]: 패스워드 최소 사용기간이 설정되어 있지 않는 경우

EOF

BAR

DEF_FILE="/etc/login.defs"

# 전에 있던 PASS_MIN_LEN 값을 #PASS_MIN_LEN
sed -i 's/PASS_MIN_DAYS/#PASS_MIN_DAYS/g' "$DEF_FILE"

echo "PASS_MIN_DAYS 7" >> "$DEF_FILE"
 
cat $result

echo ; echo
