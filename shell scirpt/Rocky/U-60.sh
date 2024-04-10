#!/bin/bash

# 변수 초기화
category="서비스 관리"
code="U-60"
severity="중"
check_item="ssh 원격접속 허용"
ssh_status=""
telnet_status=""
ftp_status=""
result=""
recommendation="SSH 사용 권장, Telnet 및 FTP 사용하지 않도록 설정"

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
