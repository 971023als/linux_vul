#!/bin/bash

# 초기 진단 결과 및 현황 설정
category="서비스 관리"
code="U-68"
severity="하"
check_item="로그온 시 경고 메시지 제공"
result=""
declare -a status
recommendation="서버 및 주요 서비스(Telnet, FTP, SMTP, DNS)에 로그온 메시지 설정"

# /etc/motd 파일 검사
if [ -s "/etc/motd" ]; then
    message_found=true
fi

# /etc/issue.net 파일 검사
if [ -s "/etc/issue.net" ]; then
    message_found=true
fi

# FTP 서비스 구성 파일 검사
ftp_configs=("/etc/vsftpd.conf" "/etc/proftpd/proftpd.conf" "/etc/pure-ftpd/conf/WelcomeMsg")
for config in "${ftp_configs[@]}"; do
    if [ -s "$config" ] && grep -Eq "(ftpd_banner|ServerIdent|WelcomeMsg)" "$config"; then
        message_found=true
    fi
done

# SMTP 서비스 구성 파일 검사 (/etc/sendmail.cf)
if [ -s "/etc/sendmail.cf" ] && grep -q "GreetingMessage" "/etc/sendmail.cf"; then
    message_found=true
fi

# 진단 결과 결정
if [ "$message_found" = true ]; then
    result="양호"
    status+=("로그온 메시지가 적절히 설정되어 있습니다.")
else
    result="취약"
    status+=("일부 또는 모든 서비스에 로그온 메시지가 설정되어 있지 않습니다.")
fi

# DNS 서비스 구성 파일 점검 안내
status+=("DNS 배너의 경우 '/etc/named.conf' 또는 '/var/named' 파일을 수동으로 점검하세요.")

# 결과 출력
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황:"
for i in "${status[@]}"; do
    echo "- $i"
done
echo "대응방안: $recommendation"
