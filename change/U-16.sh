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

# ==== 조치 결과 MD 출력 ====
_change_code="U-16"
_change_item="비 장치 파일을 검색하고 있습니다..."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
