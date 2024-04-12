#!/bin/bash

# /etc/login.defs 파일에서 패스워드 최소 길이 설정
update_login_defs() {
    sed -i '/^PASS_MIN_LEN/ s/.*/PASS_MIN_LEN    8/' /etc/login.defs
}

# PAM 설정에서 패스워드 최소 길이 설정
update_pam() {
    pam_files="/etc/pam.d/system-auth /etc/pam.d/password-auth"

    for pam_file in $pam_files; do
        if grep -q "pam_pwquality.so" "$pam_file"; then
            if ! grep "minlen=8" "$pam_file"; then
                sed -i '/pam_pwquality.so/ s/$/ minlen=8/' "$pam_file"
            fi
        else
            echo "pam_pwquality.so 설정이 $pam_file 파일에 없습니다."
        fi
    done
}

# pwquality 설정에서 패스워드 최소 길이 설정
update_pwquality() {
    if [ -f "/etc/security/pwquality.conf" ]; then
        sed -i '/^# minlen =/ s/.*/minlen = 8/' /etc/security/pwquality.conf
    else
        echo "/etc/security/pwquality.conf 파일이 존재하지 않습니다."
    fi
}

main() {
    echo "패스워드 최소 길이 설정을 업데이트합니다..."
    update_login_defs
    update_pam
    update_pwquality
    echo "U-46 업데이트 완료."
}

main
