#!/bin/bash

# SSH 서비스 상태 확인
if systemctl is-active --quiet ssh; then
    ssh_status="활성화"
else
    ssh_status="비활성화"
fi

# Telnet 서비스 상태 확인
if pgrep -f telnetd > /dev/null; then
    telnet_status="활성화"
else
    telnet_status="비활성화"
fi

# FTP 서비스 상태 확인
if pgrep -f ftpd > /dev/null; then
    ftp_status="활성화"
else
    ftp_status="비활성화"
fi

# 전체 보안 상태 결정
if [ "$ssh_status" == "활성화" ] && [ "$telnet_status" == "비활성화" ] && [ "$ftp_status" == "비활성화" ]; then
    result="양호"
else
    result="취약"
    # Telnet과 FTP 서비스 비활성화 조치
    if [ "$telnet_status" == "활성화" ]; then
        systemctl stop telnetd
        systemctl disable telnetd
        echo "Telnet 서비스가 비활성화되었습니다."
    fi
    if [ "$ftp_status" == "활성화" ]; then
        systemctl stop ftpd
        systemctl disable ftpd
        echo "FTP 서비스가 비활성화되었습니다."
    fi
    # SSH 서비스 활성화 조치
    if [ "$ssh_status" == "비활성화" ]; then
        systemctl start ssh
        systemctl enable ssh
        echo "SSH 서비스가 활성화되었습니다."
        ssh_status="활성화" # 상태 업데이트
    fi
    result="양호" # 모든 조치 후 결과 업데이트
fi

# 결과 출력
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황:"
echo "SSH 서비스 상태: $ssh_status"
echo "Telnet 서비스 상태: $telnet_status"
echo "FTP 서비스 상태: $ftp_status"
echo "대응방안: $recommendation"
