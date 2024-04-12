#!/bin/bash

# /etc/pam.d/su 파일이 있는지 확인하고, pam_wheel.so 모듈 설정을 수정함
configure_su_restriction() {
    pam_su_path="/etc/pam.d/su"

    if [ -f "$pam_su_path" ]; then
        # pam_wheel.so 설정이 이미 존재하는지 확인
        if ! grep -q "auth\s*required\s*pam_wheel.so\s*use_uid" "$pam_su_path"; then
            echo "pam_wheel.so 설정을 추가하여 su 사용을 wheel 그룹으로 제한합니다."
            # pam_wheel.so 설정을 추가
            echo "auth required pam_wheel.so use_uid" >> "$pam_su_path"
        else
            echo "su 사용이 이미 wheel 그룹으로 제한되어 있습니다."
        fi
    else
        echo "/etc/pam.d/su 파일이 존재하지 않습니다."
    fi
}

main() {
    echo "root 계정 su 제한 설정 시작..."
    configure_su_restriction
    echo "U-45 설정 완료."
}

main
