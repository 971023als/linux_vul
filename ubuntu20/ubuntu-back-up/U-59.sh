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

#    백업 파일 생성
cp $hidden_files.bak $hidden_files


hidden_dirs=$(sudo find / -type d -name ".*" ! -path "/run/user/1000/gvfs/*")

#    백업 파일 생성
cp $hidden_dirs.bak $hidden_dirs

cat $result

echo ; echo 

 
