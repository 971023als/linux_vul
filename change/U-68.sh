#!/bin/bash


# 메시지 설정 여부 판단 변수
message_found=false

# /etc/motd 파일 검사
if [ -s "/etc/motd" ]; then
    message_found=true
    status+=("/etc/motd 파일에 로그온 메시지가 설정되어 있습니다.")
fi

# /etc/issue 및 /etc/issue.net 파일 검사
if [ -s "/etc/issue.net" ]; then
    message_found=true
    status+=("/etc/issue.net 파일에 로그온 메시지가 설정되어 있습니다.")
fi

# FTP, SMTP 서비스 구성 파일 검사 및 안내
ftp_message_set=false
smtp_message_set=false

# FTP 설정 파일 검사
ftp_configs=("/etc/vsftpd.conf" "/etc/proftpd/proftpd.conf" "/etc/pure-ftpd/conf/WelcomeMsg")
for config in "${ftp_configs[@]}"; do
    if [ -s "$config" ] && grep -Eq "(ftpd_banner|ServerIdent|WelcomeMsg)" "$config"; then
        ftp_message_set=true
        status+=("$config 파일에 FTP 서비스 로그온 메시지가 설정되어 있습니다.")
    fi
done

# SMTP 설정 파일 검사
if [ -s "/etc/sendmail.cf" ] && grep -q "GreetingMessage" "/etc/sendmail.cf"; then
    smtp_message_set=true
    status+=("/etc/sendmail.cf 파일에 SMTP 서비스 로그온 메시지가 설정되어 있습니다.")
fi

# DNS 서비스 구성 파일 점검 안내
status+=("DNS 서비스 로그온 메시지 설정은 '/etc/named.conf' 파일을 수동으로 점검하세요.")

# 진단 결과 결정
if [ "$message_found" = true ] || [ "$ftp_message_set" = true ] || [ "$smtp_message_set" = true ]; then
    result="양호"
else
    result="취약"
    status+=("일부 또는 모든 서비스에 로그온 메시지가 설정되어 있지 않습니다.")
fi

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
