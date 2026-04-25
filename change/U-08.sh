#!/bin/bash

# /etc/shadow 파일의 경로
shadow_file="/etc/shadow"

# /etc/shadow 파일의 소유자와 권한 검사 및 조정
if [ -f "$shadow_file" ]; then
    # 소유자를 root로 설정
    chown root:root "$shadow_file"
    
    # 권한을 400으로 설정
    chmod 400 "$shadow_file"
    
    echo "U-08 /etc/shadow 파일의 소유자와 권한이 조정되었습니다."
else
    echo "U-08 /etc/shadow 파일이 존재하지 않습니다."
fi

# ==== 조치 결과 MD 출력 ====
_change_code="U-08"
_change_item="U-08 /etc/shadow 파일의 소유자와 권한이 "
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
