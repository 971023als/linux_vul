#!/bin/bash

. function.sh

BAR

CODE [U-01] root 계정 원격 접속 제한

cat << EOF >> $result

[양호]: 원격 서비스를 사용하지 않거나 사용시 직접 접속을 차단한 경우

[취약]: root 직접 접속을 허용하고 원격 서비스를 사용하는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# Backup the original /etc/securety and /etc/pam.d/login files
cp /etc/securety /etc/securety.bak
cp /etc/pam.d/login /etc/pam.d/login.bak

cat $result

echo ; echo