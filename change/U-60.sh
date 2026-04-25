#!/bin/bash

# SSH, Telnet, FTP 서비스 상태 확인 및 Telnet과 FTP 비활성화 스크립트

# SSH 서비스 상태 확인
check_ssh() {
    echo "SSH 서비스 상태 확인 중..."
    if systemctl is-active --quiet sshd || systemctl is-active --quiet ssh; then
        echo "U-60 SSH 서비스가 활성화되어 있습니다."
    else
        echo "U-60 SSH 서비스가 비활성화되어 있습니다."
    fi
}

# Telnet 서비스 비활성화
disable_telnet() {
    echo "Telnet 서비스 비활성화 중..."
    if systemctl is-active --quiet telnet.socket; then
        systemctl stop telnet.socket
        systemctl disable telnet.socket
        echo "U-60 Telnet 서비스를 비활성화했습니다."
    else
        echo "U-60 Telnet 서비스가 이미 비활성화되어 있습니다."
    fi
}

# FTP 서비스 비활성화
disable_ftp() {
    echo "FTP 서비스 비활성화 중..."
    if systemctl is-active --quiet vsftpd; then
        systemctl stop vsftpd
        systemctl disable vsftpd
        echo "U-60 FTP 서비스를 비활성화했습니다."
    else
        echo "U-60 FTP 서비스가 이미 비활성화되어 있습니다."
    fi
}

main() {
    check_ssh
    disable_telnet
    disable_ftp
}

main

# ==== 조치 결과 MD 출력 ====
_change_code="U-60"
_change_item="SSH 서비스 상태 확인 중..."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
