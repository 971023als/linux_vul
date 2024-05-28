#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="로그 관리"
code="U-72"
riskLevel="하"
diagnosisItem="정책에 따른 시스템 로깅 설정"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: /etc/rsyslog.conf 파일의 내용이 정확합니다.
[취약]: /etc/rsyslog.conf 파일의 내용이 잘못되었습니다.
EOF

filename="/etc/rsyslog.conf"
expected_content=(
    "*.info;mail.none;authpriv.none;cron.none /var/log/messages"
    "authpriv.* /var/log/secure"
    "mail.* /var/log/maillog"
    "cron.* /var/log/cron"
    "*.alert /dev/console"
    "*.emerg *"
)

# Check for the existence of the logging file
if [ ! -e "$filename" ]; then
    diagnosisResult="$filename 파일이 존재하지 않습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    # Check the contents of the logging file
    content_mismatch=false
    for content in "${expected_content[@]}"; do
        if ! grep -Fxq "$content" "$filename"; then
            content_mismatch=true
            diagnosisResult="$filename 파일의 내용이 잘못되었습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            break
        fi
    done

    if [ "$content_mismatch" = false ]; then
        diagnosisResult="$filename 파일의 내용이 정확합니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
