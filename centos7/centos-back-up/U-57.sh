#!/bin/bash

. function.sh

BAR

CODE [U-57] 홈 디렉터리 소유자 및 권한

cat << EOF >> $result

[양호]: 홈 디렉터리 소유자가 해당 계정이고, 일반 사용자 쓰기 권한이 제거된 경우

[취약]: 홈 디렉터리 소유자가 해당 계정이 아니고, 일반 사용자 쓰기 권한이 부여된 경우 

EOF

BAR

# /etc/passwd 파일을 읽고 홈 디렉토리 추출
output=$(cat /etc/passwd | awk -F ':' '{print $6}')

# 출력을 배열로 분할
IFS=$'\n' read -d '' -r -a arr <<< "$output"

# 배열을 반복하여 각 홈 디렉토리 확인
for line in "${arr[@]}"
do
  # 디렉토리에 다른 사용자에 대한 쓰기 권한이 있는지 확인합니다
  if [ -w "$line" ] && ! [[ -O "$line" ]]; then
  permissions=$(ls -ld $line | awk '{print $1}')
  owner=$(ls -ld $line | awk '{print $3}')
  group=$(ls -ld $line | awk '{print $4}')
  INFO "$line($owner 및 group $group 소유)에 대한 소유권 및 권한 변경"
  chown $owner:$group $line
  chmod 750 $line
  fi
done

cat $result

echo ; echo 


 
