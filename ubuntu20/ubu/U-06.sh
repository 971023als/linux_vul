#!/bin/bash

. function.sh

BAR

CODE [U-06] 파일 및 디렉터리 소유자 설정 @@su 말고 sudo su 해야 함 @@

cat << EOF >> $result

[양호]: 소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않는 경우

[취약]: 소유자가 존재하지 않는 파일 및 디렉터리가 존재하는 경우

EOF

BAR 

invalid_owner_files=$(find /root/ -nouser -print 2>/dev/null)

if [ -z "$invalid_owner_files" ]; then
  OK "잘못된 소유자가 있는 파일 또는 디렉터리를 찾을 수 없습니다"
else
  INFO "잘못된 소유자가 있는 다음 파일 또는 디렉터리에 대한 액세스 제한:"
  INFO "$invalid_owner_files"
  chown root $invalid_owner_files
fi

cat $result

echo ; echo