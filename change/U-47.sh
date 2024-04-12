#!/bin/bash

# /etc/login.defs 파일에서 패스워드 최대 사용 기간 설정
update_login_defs() {
    # 패스워드 최대 사용 기간을 90일로 설정
    echo "패스워드 최대 사용 기간을 90일로 설정합니다."
    sed -i '/^PASS_MAX_DAYS/ s/[0-9]\+/90/' /etc/login.defs
}

# PAM 설정에서 패스워드 최대 사용 기간 설정
update_pam() {
    # /etc/pam.d/common-password 파일에서 패스워드 정책을 수정
    if grep -q "pam_pwhistory.so" "/etc/pam.d/common-password"; then
        echo "PAM 설정에서 패스워드 최대 사용 기간을 90일로 설정합니다."
        sed -i '/pam_pwhistory.so/ s/remember=[0-9]\+/remember=90/' /etc/pam.d/common-password
    else
        echo "pam_pwhistory.so 설정이 /etc/pam.d/common-password 파일에 없습니다."
    fi
}

main() {
    echo "패스워드 최대 사용 기간 설정을 업데이트합니다..."
    update_login_defs
    update_pam
    echo "U-47 업데이트 완료."
}

main
