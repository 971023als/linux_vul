#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-70"
riskLevel="중"
diagnosisItem="expn, vrfy 명령어 제한"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: SMTP 서비스에서 noexpn 및 novrfy 옵션이 적절히 설정되어 있습니다.
[취약]: 일부 sendmail.cf 파일에 noexpn, novrfy 또는 goaway 설정이 적절히 설정되어 있지 않습니다.
EOF

# Check for SMTP service
if ! ps -ef | grep -Ei 'smtp|sendmail' | grep -v 'grep' > /dev/null; then
    diagnosisResult="SMTP 서비스 미사용."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    # Find sendmail.cf files
    sendmailcf_files=$(find / -name sendmail.cf -type f 2>/dev/null)
    if [[ -z "$sendmailcf_files" ]]; then
        diagnosisResult="SMTP 서비스 사용 중이나, noexpn, novrfy 또는 goaway 옵션을 설정할 수 있는 sendmail.cf 파일이 없습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        restriction_found=false
        for file_path in $sendmailcf_files; do
            if [[ -f "$file_path" ]]; then
                if grep -Eiq 'PrivacyOptions.*noexpn' "$file_path" && grep -Eiq 'PrivacyOptions.*novrfy' "$file_path" || grep -Eiq 'PrivacyOptions.*goaway' "$file_path"; then
                    restriction_found=true
                    break
                fi
            fi
        done
        
        if $restriction_found; then
            diagnosisResult="SMTP 서비스에서 noexpn 및 novrfy 옵션이 적절히 설정되어 있습니다."
            status="양호"
            echo "OK: $diagnosisResult" >> $TMP1
        else
            diagnosisResult="일부 sendmail.cf 파일에 noexpn, novrfy 또는 goaway 설정이 적절히 설정되어 있지 않습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
        fi
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
