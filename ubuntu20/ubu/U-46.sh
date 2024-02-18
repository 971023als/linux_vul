#!/bin/bash

. function.sh

BAR

CODE [U-46] 패스워드 최소 길이 설정

cat << EOF >> $result

[양호]: 패스워드 최소 길이가 8자 이상으로 설정되어 있는 경우 

[취약]: 패스워드 최소 길이가 8자 미만으로 설정되어 있는 경우 

EOF

BAR 

DEF_FILE="/etc/login.defs"

# 전에 있던 PASS_MIN_LEN 값을 #PASS_MIN_LEN
sed -i 's/PASS_MIN_LEN/#PASS_MIN_LEN/g' "$DEF_FILE"

echo "PASS_MIN_LEN 8" > "$DEF_FILE"

cat $result

echo ; echo