#!/bin/bash

# FTP 서비스 비활성화 스크립트

# FTP 서비스 실행 중지 및 비활성화
disable_ftp_services() {
    echo "FTP 서비스 비활성화 중..."

    # vsftpd 서비스 확인 및 비활성화
    if systemctl is-active --quiet vsftpd; then
        systemctl stop vsftpd
        systemctl disable vsftpd
        echo "vsftpd 서비스를 비활성화했습니다."
    fi

    # proftpd 서비스 확인 및 비활성화
    if systemctl is-active --quiet proftpd; then
        systemctl stop proftpd
        systemctl disable proftpd
        echo "proftpd 서비스를 비활성화했습니다."
    fi

    # FTP 관련 포트가 열려있는지 확인 (21번 포트 사용)
    if ss -tuln | grep -q ':21 '; then
        echo "U-61 FTP 포트(21)가 열려 있습니다. 서비스 또는 방화벽 설정을 확인하세요."
    else
        echo "U-61 FTP 포트(21)가 닫혀 있습니다."
    fi
}

main() {
    disable_ftp_services
}

main
