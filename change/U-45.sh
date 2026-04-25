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

# ==== 조치 결과 MD 출력 ====
_change_code="U-45"
_change_item="pam_wheel.so 설정을 추가하여 su 사용을 w"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
