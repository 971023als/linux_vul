#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

>$TMP1  

BAR

CODE [U-15] world writable 파일 점검

cat << EOF >> $result  

[양호]: world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인하고 있는 경우

[취약]: world writable 파일이 존재하나 해당 설정 이유를 확인하고 있지 않은 경우

EOF

BAR

if find / -type f -perm 777 | grep -q . ; then
  WARN "world writeable 파일이 있습니다"
else
  OK "world writeable 파일이 없습니다."
fi
 
cat $result

echo ; echo

 
