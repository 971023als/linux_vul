#!/bin/bash

dev_directory='/dev'

# /dev 디렉터리 검사 및 캐릭터 또는 블록 디바이스가 아닌 파일 제거
find "$dev_directory" -type f -exec sh -c '
    for item do
        if [ ! -c "$item" ] && [ ! -b "$item" ]; then
            echo "제거됨: $item"
            rm -f "$item"
        fi
    done
' sh {} +

echo "/dev 디렉터리 내 존재하지 않는 device 파일의 제거가 완료되었습니다."
