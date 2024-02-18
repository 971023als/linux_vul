#!/bin/bash

 

. function.sh

 

TMP1=`SCRIPTNAME`.log

> $TMP1  

 

BAR

CODE [U-59] 숨겨진 파일 및 디렉터리 검색 및 제거

cat << EOF >> $result

[양호]: 디렉터리 내 숨겨진 파일을 확인하여, 불필요한 파일 삭제를 완료한 경우

[취약]: 디렉터리 내 숨겨진 파일을 확인하지 않고, 불필요한 파일을 방치한 경우

EOF

BAR


rootdir="/home/user/"

# 숨겨진 모든 파일 및 디렉터리 나열
hidden_files=$(find "$rootdir" -type f -name ".*" ! -name ".*.swp")
hidden_dirs=$(find "$rootdir" -type d -name ".*" ! -name ".*.swp")

# 원하지 않거나 의심스러운 파일 또는 디렉터리가 있는지 확인
for file in $hidden_files; do
  if [[ $(basename $file) =~ "unwanted-file" ]]; then
    WARN "원하지 않는 파일: $file"
  else
    OK "정상적인 파일: $file"
  fi
done

for dir in $hidden_dirs; do
  if [[ $(basename $dir) =~ "suspicious-dir" ]]; then
    WARN "의심스러운 디렉토리: $dir"
  else
    OK "정상적인 디렉터리: $dir"
  fi
done


cat $result

echo ; echo 

 
