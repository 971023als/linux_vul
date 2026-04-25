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


# ==== MD OUTPUT (stdout — shell_runner.sh 가 캡처하여 stdout.txt 저장) ====
_md_code="${code:-${CODE:-U-??}}"
_md_category="${category:-}"
_md_risk="${riskLevel:-${severity:-}}"
_md_item="${diagnosisItem:-${check_item:-진단항목}}"
_md_result="${diagnosisResult:-${result:-}}"
_md_status="${status:-${details:-${service:-}}}"
_md_solution="${solution:-${recommendation:-}}"

cat << __MD_EOF__
# ${_md_code}: ${_md_item}

| 항목 | 내용 |
|------|------|
| 분류 | ${_md_category} |
| 코드 | ${_md_code} |
| 위험도 | ${_md_risk} |
| 진단항목 | ${_md_item} |
| 진단결과 | ${_md_result} |
| 현황 | ${_md_status} |
| 대응방안 | ${_md_solution} |
__MD_EOF__
