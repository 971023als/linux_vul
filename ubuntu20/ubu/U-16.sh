#!/bin/bash

. function.sh

BAR

CODE [U-16] /dev에 존재하지 않는 device 파일 점검

cat << EOF >> $result  

[양호]: dev에 대한 파일 점검 후 존재하지 않은 device 파일을 제거한 경우

[취약]: dev에 대한 파일 미점검, 또는, 존재하지 않은 device 파일을 방치한 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# 주 번호 또는 부 번호가 없는 /dev 디렉토리에서 파일 찾기
find /dev -type f -exec ls -l {} \; | awk '$5 == "0" && $6 == "0" {print $9}' |
for read file; do
  # 삭제하기 전에 디바이스 파일 확인
  if [ -b "$file" ]; then
    #  변수 할당
    major=$(stat -c %t "$file")
    minor=$(stat -c %T "$file")

    #메이저 마이너 확인
    if [ -z "$major" ] || [ -z "$minor" ]; then
      # 삭제
      rm -f "$file"
    fi
  fi
done
 
cat $result

echo ; echo

