#!/bin/bash

# 기본 소유자 및 그룹 설정
DEFAULT_USER="root"
DEFAULT_GROUP="root"

# /tmp 디렉터리에서 소유자나 그룹이 없는 파일 및 디렉터리 찾기
find /tmp -nouser -o -nogroup | while read -r file; do
    echo "소유자 또는 그룹이 없는 파일/디렉터리를 발견: $file"
    
    # 소유자 및 그룹을 기본값으로 설정
    chown $DEFAULT_USER:$DEFAULT_GROUP "$file"
    echo "U-06 조치 완료: $file -> 소유자: $DEFAULT_USER, 그룹: $DEFAULT_GROUP"
done
