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

#  출력을 배열로 분할
arr=($output)

# 출력을 배열로 분할
for line in "${arr[@]}"
do
  permissions=$(ls -ld $line | awk '{print $1}')
  owner=$(ls -ld $line | awk '{print $3}')
  group=$(ls -ld $line | awk '{print $4}')
  if [[ $permissions == *"w"* ]] && [[ $owner != *$group* ]]; then
    WARN "write 권한은 $line($owner 및 group $group 소유)에서 다른 사용자에게 부여됩니다."  
  else
    OK "write 권한은 $line($owner 및 group $group 소유)에서 다른 사용자에게 부여됩니다."  
  fi
done

cat $result

echo ; echo 


 
