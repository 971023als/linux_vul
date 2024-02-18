#!/bin/bash

 

. function.sh

 

TMP1=`SCRIPTNAME`.log

>$TMP1

 

 

BAR

CODE [U-09] /etc/hosts 파일 소유자 및 권한 설정.

cat << EOF >> $result

[양호]: /etc/hosts 파일의 소유자가 root이고, 권한이 600 이하경우

[취약]: /etc/hosts 파일의 소유자가 root가 아니거나, 권한이 600 이상인 경우

EOF

BAR
 

file="/etc/hosts"

# 소유권 확인
owner=$(stat -c '%U' "$file")
if [ "$owner" != "root" ]; then
  WARN "$file의 소유자가 루트가 아니라 $owner가 소유하고 있다."
else
  OK "$file의 소유자는 루트입니다."
fi

# 권한 확인
permissions=$(stat -c '%a' "$file")
if [ "$permissions" -lt 600 ]; then
  WARN "$file의 권한이 600 미만입니다. $permissions 설정."
else
  OK "$file의 권한은 최소 600 입니다."
fi
 


cat $result

echo ; echo
