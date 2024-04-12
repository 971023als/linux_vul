#!/bin/bash

# /etc/hosts.lpd 파일의 존재 여부, 소유자, 권한 확인 및 조치 스크립트

check_and_fix_hosts_lpd() {
    local file_path="/etc/hosts.lpd"

    if [[ -f "$file_path" ]]; then
        # 파일의 소유자와 권한 확인
        local owner_uid=$(stat -c "%u" "$file_path")
        local permissions=$(stat -c "%a" "$file_path")

        # 소유자가 root가 아니거나 권한이 600이 아닌 경우 조치
        if [[ "$owner_uid" != "0" ]] || [[ "$permissions" != "600" ]]; then
            echo "조치: $file_path 파일의 소유자를 root로 변경하고 권한을 600으로 설정합니다."
            chown root:root "$file_path"
            chmod 600 "$file_path"
        else
            echo "U-55 $file_path 파일의 소유자와 권한이 이미 적절하게 설정되어 있습니다."
        fi
    else
        echo "U-55 $file_path 파일이 존재하지 않습니다. 별도 조치가 필요하지 않습니다."
    fi
}

main() {
    check_and_fix_hosts_lpd
}

main
