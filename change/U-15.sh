#!/bin/bash

# 검사 시작 디렉터리 설정
start_dir='/tmp'  # 전체 시스템 스캔을 위해 필요에 따라 변경 가능

# world writable 파일 권한 제거
find "$start_dir" -type f -perm -002 -print0 | while IFS= read -r -d '' file; do
    chmod o-w "$file"
    echo "world writable 권한이 제거되었습니다: $file"
done

echo "모든 world writable 파일에서 권한이 제거되었습니다."
