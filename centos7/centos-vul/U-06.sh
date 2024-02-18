#!/bin/bash

 

. function.sh

 

TMP1=$(SCRIPTNAME).log

> $TMP1

BAR

CODE [U-06] 파일 및 디렉토리 소유자 설정

cat << EOF >> $result

[양호]: 소유자가 존재하지 않은 파일 및 디렉터리가 존재하지 않는 경우

[취약]: 소유자가 존재하지 않은 파일 및 디렉터리가 존재하는 경우

EOF

BAR


invalid_owner_files=$(find /root/ -nouser -print 2>/dev/null)

if [ -z "$invalid_owner_files" ]; then
  OK "잘못된 소유자가 있는 파일 또는 디렉터리를 찾을 수 없습니다"
else
  INFO "다음 파일 또는 디렉터리의 소유자가 의심됩니다."
  INFO "$invalid_owner_files"
fi
 
cat $result

echo ; echo
