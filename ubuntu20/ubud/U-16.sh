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

# primary or minor numbers 없는 백업 장치 파일
mkdir -p /root/device_files_backup
for file in $(find /dev -type f -exec ls -l {} \; | awk '$5 == "0" && $6 == "0" {print $9}')
do
  if [ -b "$file" ]; then
    major=$(stat -c %t "$file")
    minor=$(stat -c %T "$file")
    if [ -z "$major" ] || [ -z "$minor" ]; then
      # device file backup
      cp -p "$file" /root/device_files_backup/
    fi
  fi
done


# INFO "primary / minor numbers 가 없는 장치 파일을 백업하였습니다."

INFO "/root/device_files_backup/에 백업된 파일을 확인하시기 바랍니다."

#---------------------------------------------------


# 백업된 장치 파일 복원
find /root/device_files_backup -type f -exec cp -p {} /dev/ \;
 

# INFO "백업된 장치 파일을 복원하였습니다."
 
INFO "/root/device_files_backup/으로부터 복구한 파일을 확인하시기 바랍니다."

cat $result

echo ; echo

