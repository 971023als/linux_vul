#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-42] 최신 보안패치 및 벤더 권고사항 적용

cat << EOF >> $result

[양호]: 패치 적용 정책을 수립하여 주기적으로 패치를 관리하고 있는 경우

[취약]: 패치 적용 정책을 수립하지 않고 주기적으로 패치관리를 하지 않는 경우

EOF

BAR

# 현재 날짜 가져오기
current_date=$(date +%Y-%m-%d)

# /var/log/patch.log에 "$current_date에 설치된 패치" 행이 있는지 확인합니다
grep "Patches installed on $current_date" /var/log/patch.log > /dev/null 2>&1

# If the exit status of grep is 0, the line exists in the file
if [ $? -eq 0 ]; then
  OK "'$current_date 에 설치된 패치' 행이 /var/log/patch.log에 있습니다."
else
  WARN "'$current_date 에 설치된 패치' 행이 /var/log/patch.log에 없습니다."
fi

cat $result

echo ; echo 

 
