#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-69"
riskLevel="중"
diagnosisItem="NFS 설정파일 접근권한"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: NFS 접근제어 설정파일의 소유자가 root이고, 권한이 644 이하입니다.
[취약]: /etc/exports 파일의 소유자(owner)가 root가 아니거나 권한이 644보다 큽니다.
EOF

exports_file='/etc/exports'

if [ -e "$exports_file" ]; then
    # Get the file's mode (permissions and ownership)
    mode=$(stat -c "%a" "$exports_file")
    owner_uid=$(stat -c "%u" "$exports_file")

    # Check if owner is root and file permissions are 644 or less
    if [ "$owner_uid" -eq 0 ] && [ "$mode" -le 644 ]; then
        diagnosisResult="NFS 접근제어 설정파일의 소유자가 root이고, 권한이 644 이하입니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult=""
        status="취약"
        if [ "$owner_uid" -ne 0 ]; then
            diagnosisResult="/etc/exports 파일의 소유자(owner)가 root가 아닙니다."
            echo "WARN: $diagnosisResult" >> $TMP1
        fi
        if [ "$mode" -gt 644 ]; then
            diagnosisResult="${diagnosisResult:+$diagnosisResult }/etc/exports 파일의 권한이 644보다 큽니다."
            echo "WARN: $diagnosisResult" >> $TMP1
        fi
    fi
else
    diagnosisResult="/etc/exports 파일이 없습니다."
    status="N/A"
    echo "INFO: $diagnosisResult" >> $TMP1
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
