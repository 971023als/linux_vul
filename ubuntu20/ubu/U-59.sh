#!/bin/bash

. function.sh

BAR

CODE [U-59] 숨겨진 파일 및 디렉터리 검색 및 제거

cat << EOF >> $result

[양호]: 디렉터리 내 숨겨진 파일을 확인하여, 불필요한 파일 삭제를 완료한 경우

[취약]: 디렉터리 내 숨겨진 파일을 확인하지 않고, 불필요한 파일을 방치한 경우

EOF

BAR

# 숨김 파일 및 디렉토리 정의
hidden_files=$(sudo find / -type f -name ".*" ! -path "/run/user/1000/gvfs/*")
hidden_dirs=$(sudo find / -type d -name ".*" ! -path "/run/user/1000/gvfs/*")

# 원치 않거나 의심스러운 파일이나 디렉토리가 있는지 확인
for file in $hidden_files; do
  if [[ $(basename $file) =~ "unwanted-file" ]]; then
    INFO "원하지 않는 파일 발견: $file"
     # 파일 삭제 또는 알림 전송과 같은 원하는 작업을 수행합니다.
    rm $file
  fi
done

for dir in $hidden_dirs; do
  if [[ $(basename $dir) =~ "suspicious-dir" ]]; then
    INFO "수상한 디렉토리를 찾았습니다: $dir"
    # 디렉터리 삭제 또는 알림 전송과 같은 원하는 작업을 수행합니다.
    rm -r $dir
  fi
done

cat $result

echo ; echo 

 
