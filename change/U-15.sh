#!/bin/bash

# 시작 디렉터리 설정
# 전체 시스템을 스캔하고 싶다면 start_dir="/"로 설정하세요. 
# 단, 전체 시스템 스캔은 시스템에 부하를 줄 수 있으므로 주의하여 실행하세요.
start_dir="/tmp"

# world writable 파일 찾기 및 권한 조정
find "$start_dir" -type f -perm -002 -exec echo "World writable 파일 찾음: {}" \; -exec chmod o-w {} \; 

echo "U-15 World writable 파일의 권한 조정이 완료되었습니다."
