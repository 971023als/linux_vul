#!/bin/bash
 
. function.sh

TMP1=`SCRIPTNAME`.log

>$TMP1  
 
BAR

CODE [U-16] /dev에 존재하지 않는 device 파일 점검

cat << EOF >> $result  

[양호]: dev에 대한 파일 점검 후 존재하지 않은 device 파일을 제거한 경우

[취약]: dev에 대한 파일 미점검, 또는, 존재하지 않은 device 파일을 방치한 경우

EOF

BAR

results=$(find /dev -type f -exec ls -l {} \;)

while read line; do
  major_minor=$(echo $line | awk '{print $5,$6}')
  if [ "$major_minor" == "0 0" ]; then
    WARN "$line 메이저 및 마이너 번호가 없는 장치를 찾았습니다"
  else
    OK "$line 메이저 및 마이너 번호가 있습니다"
  fi
done <<< "$results"

cat $result

echo ; echo

