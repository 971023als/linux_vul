#!/bin/bash

exports_file="/etc/exports"

if [ -f "$exports_file" ]; then
    # 소유자를 root으로 변경
    sudo chown root:root "$exports_file"
    # 권한을 644로 설정
    sudo chmod 644 "$exports_file"
    
    echo "U-69 /etc/exports 파일의 소유자와 권한을 적절하게 설정하였습니다."
else
    echo "U-69 /etc/exports 파일이 존재하지 않습니다. NFS가 설치되지 않았거나 다른 위치에 설정 파일이 있을 수 있습니다."
fi

# ==== 조치 결과 MD 출력 ====
_change_code="U-69"
_change_item="U-69 /etc/exports 파일의 소유자와 권한을"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
