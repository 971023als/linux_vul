#!/bin/bash

# 패스워드 복잡성 설정
echo "패스워드 복잡성 설정 조치 중..."

# /etc/login.defs에서 패스워드 최소 길이 설정
echo "패스워드 최소 길이 설정 중..."
if ! grep -q "^PASS_MIN_LEN" /etc/login.defs; then
    echo "PASS_MIN_LEN 8" >> /etc/login.defs
else
    sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 8/' /etc/login.defs
fi

# PAM 설정을 통한 복잡성 요구사항 설정
update_pam() {
    local pam_file=$1
    if [ -f "$pam_file" ]; then
        if ! grep -q "pam_pwquality.so" $pam_file; then
            echo "password requisite pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=" >> $pam_file
        fi
        sed -i '/pam_pwquality.so/c\password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type= minlen=8 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1' $pam_file
    fi
}

echo "PAM 설정 업데이트 중..."
update_pam "/etc/pam.d/system-auth"
update_pam "/etc/pam.d/password-auth"

# /etc/security/pwquality.conf 설정 업데이트
echo "/etc/security/pwquality.conf 설정 조정 중..."
if [ -f "/etc/security/pwquality.conf" ]; then
    sed -i 's/^# minlen =.*/minlen = 8/' /etc/security/pwquality.conf
    sed -i 's/^# dcredit =.*/dcredit = -1/' /etc/security/pwquality.conf
    sed -i 's/^# ucredit =.*/ucredit = -1/' /etc/security/pwquality.conf
    sed -i 's/^# lcredit =.*/lcredit = -1/' /etc/security/pwquality.conf
    sed -i 's/^# ocredit =.*/ocredit = -1/' /etc/security/pwquality.conf
fi

echo "U-02 패스워드 복잡성 설정이 업데이트되었습니다."
