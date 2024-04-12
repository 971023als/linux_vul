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
