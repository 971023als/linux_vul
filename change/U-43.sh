#!/bin/bash

# 로그 파일의 존재를 확인하고, 존재하지 않는 경우 생성
check_and_create_log() {
    local log_path="$1"

    if [ ! -f "$log_path" ]; then
        echo "Creating missing log file: $log_path"
        touch "$log_path"
    else
        echo "Log file exists: $log_path"
    fi
}

main() {
    declare -A log_files=(
        ["/var/log/utmp"]=""
        ["/var/log/wtmp"]=""
        ["/var/log/btmp"]=""
        ["/var/log/sulog"]=""
        ["/var/log/xferlog"]=""
    )

    for log_path in "${!log_files[@]}"; do
        check_and_create_log "$log_path"
    done

    echo "U-43 Log review and reporting script completed."
}

main

# ==== 조치 결과 MD 출력 ====
_change_code="U-43"
_change_item="Creating missing log file: $lo"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
