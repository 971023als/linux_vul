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


adiosdir="/home/adiosl/"

# List all hidden files and directories
hidden_files=$(find "$adiosdir" -type f -name ".*" ! -name ".*.swp")
hidden_dirs=$(find "$adiosdir" -type d -name ".*" ! -name ".*.swp")

# Check if any unwanted or suspicious files or directories exist
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


cubridir="/home/cubrid/"

# List all hidden files and directories
hidden_file=$(find "$cubridir" -type f -name ".*" ! -name ".*.swp")
hidden_dir=$(find "$cubridir" -type d -name ".*" ! -name ".*.swp")

# Check if any unwanted or suspicious files or directories exist
for file in $hidden_file; do
  if [[ $(basename $file) =~ "unwanted-file" ]]; then
    WARN "원하지 않는 파일: $file"
  else
    OK "정상적인 파일: $file"
  fi
done

for dir in $hidden_dir; do
  if [[ $(basename $dir) =~ "suspicious-dir" ]]; then
    WARN "의심스러운 디렉토리: $dir"
  else
    OK "정상적인 디렉터리: $dir"
  fi
done


cat $result

echo ; echo 

 
