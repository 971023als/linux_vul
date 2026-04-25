#!/bin/bash

# syslog 관련 파일들
syslog_conf_files=("/etc/rsyslog.conf" "/etc/syslog.conf" "/etc/syslog-ng.conf")

# 파일 소유자 및 권한 설정 함수
set_file_ownership_and_permissions() {
    file_path=$1
    if [ -f "$file_path" ]; then
        # 소유자를 root로 설정
        chown root:root "$file_path"
        # 권한을 640으로 설정
        chmod 640 "$file_path"
        echo "U-11 $file_path 파일의 소유자와 권한이 조정되었습니다."
    else
        echo "U-11 $file_path 파일이 존재하지 않습니다."
    fi
}

# 각 syslog 파일에 대해 조치 적용
for file_path in "${syslog_conf_files[@]}"; do
    set_file_ownership_and_permissions "$file_path"
done

# ==== 조치 결과 MD 출력 ====
_change_code="U-11"
_change_item="U-11 $file_path 파일의 소유자와 권한이 조"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
