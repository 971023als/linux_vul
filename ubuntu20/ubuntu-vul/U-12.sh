#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

>$TMP1  

BAR

CODE [U-12] /etc/services 파일 소유자 및 권한 설정 

cat << EOF >> $result  

[양호]: /etc/services 파일의 소유자가 root이고, 권한이 644 이하

[취약]: /etc/services 파일의 소유자가 root가 아니거나, 권한이 644 이상

EOF

BAR


file="/etc/services"

# 소유권확인
owner=$(stat -c '%U' "$file")
if [ "$owner" != "root" ] && [ "$owner" != "bin" ] && [ "$owner" != "sys" ]; then
  WARN "$file의 소유자가 root, bin, sys가 아니고 $owner 가 소유하고 있다."
else
  OK "$file의 소유자는 root, bin 또는 sys입니다."
fi

# Check permissions
permissions=$(stat -c '%a' "$file")
if [ "$permissions" -gt 644 ]; then
  WARN "$file의 권한이 644보다 큽니다. $permissions 으로 설정."
else
  OK "$file의 권한이 644 이하입니다."
fi

cat $result

echo ; echo
