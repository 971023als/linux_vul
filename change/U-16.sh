#!/bin/bash

# /dev 디렉터리 설정
dev_directory="/dev"

# /dev 내의 비 장치 파일 찾기 및 제거
echo "비 장치 파일을 검색하고 있습니다..."
find "$dev_directory" -type f | while read -r file; do
    if [[ ! -c "$file" && ! -b "$file" ]]; then  # 문자 장치 파일(c) 또는 블록 장치 파일(b)이 아닌 경우
        echo "비 장치 파일 제거: $file"
        rm -f "$file"
    fi
done

echo "U-16 /dev 디렉터리 내의 비 장치 파일 제거 작업이 완료되었습니다."
