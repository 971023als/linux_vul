#!/bin/bash

# 패스워드 정책 설정을 위한 변수 정의
min_length=8
lcredit=-1
ucredit=-1
dcredit=-1
ocredit=-1

# PAM 모듈 설정 업데이트
update_pam_module() {
    local pam_file="$1"
    if [[ -f "$pam_file" ]]; then
        if ! grep -q "pam_pwquality.so" "$pam_file"; then
            echo "password requisite pam_pwquality.so retry=3" >> "$pam_file"
        fi
        sed -i "/pam_pwquality.so/c\password    requisite     pam_pwquality.so try_first_pass retry=3 minlen=$min_length dcredit=$dcredit ucredit=$ucredit lcredit=$lcredit ocredit=$ocredit" "$pam_file"
    fi
}

# /etc/login.defs 설정 업데이트
update_login_defs() {
    sed -i "/^PASS_MAX_DAYS/c\PASS_MAX_DAYS   99999" /etc/login.defs
    sed -i "/^PASS_MIN_DAYS/c\PASS_MIN_DAYS   0" /etc/login.defs
    sed -i "/^PASS_MIN_LEN/c\PASS_MIN_LEN    $min_length" /etc/login.defs
    sed -i "/^PASS_WARN_AGE/c\PASS_WARN_AGE   7" /etc/login.defs
}

# /etc/security/pwquality.conf 설정 업데이트
update_pwquality_conf() {
    local conf_file="/etc/security/pwquality.conf"
    if [[ -f "$conf_file" ]]; then
        sed -i "/^minlen/c\minlen = $min_length" "$conf_file"
        sed -i "/^dcredit/c\dcredit = $dcredit" "$conf_file"
        sed -i "/^ucredit/c\ucredit = $ucredit" "$conf_file"
        sed -i "/^lcredit/c\lcredit = $lcredit" "$conf_file"
        sed -i "/^ocredit/c\ocredit = $ocredit" "$conf_file"
    fi
}

# PAM 설정 파일 업데이트
update_pam_module "/etc/pam.d/system-auth"
update_pam_module "/etc/pam.d/password-auth"

# /etc/login.defs와 /etc/security/pwquality.conf 설정 업데이트
update_login_defs
update_pwquality_conf

echo "패스워드 정책이 업데이트되었습니다."

