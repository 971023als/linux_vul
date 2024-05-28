#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-68"
riskLevel="하"
diagnosisItem="로그온 시 경고 메시지 제공"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 로그온 메시지가 적절히 설정되어 있습니다.
[취약]: 일부 또는 모든 서비스에 로그온 메시지가 설정되어 있지 않습니다.
EOF

message_found=false

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
    diagnosisResult="로그온 메시지가 적절히 설정되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    diagnosisResult="일부 또는 모든 서비스에 로그온 메시지가 설정되어 있지 않습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

# DNS 서비스 구성 파일 점검 안내
dns_notice="DNS 배너의 경우 '/etc/named.conf' 또는 '/var/named' 파일을 수동으로 점검하세요."
echo "INFO: $dns_notice" >> $TMP1

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
