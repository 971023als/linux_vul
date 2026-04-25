#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-19"
riskLevel="상"
diagnosisItem="Finger 서비스 비활성화"
solution="Finger 서비스가 비활성화 되어 있는 경우"
diagnosisResult=""
status=""

# Initial log file
TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: Finger 서비스가 비활성화되어 있거나 실행 중이지 않은 경우
[취약]: Finger 서비스가 활성화되어 있거나 실행 중인 경우
EOF

# Check if /etc/services contains Finger service definition
if grep -iq "^finger.*tcp" /etc/services; then
    diagnosisResult="/etc/services에 Finger 서비스 포트가 정의되어 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    if [ ! -f "/etc/services" ]; then
        diagnosisResult="/etc/services 파일을 찾을 수 없습니다."
        status="정보 없음"
        echo "INFO: $diagnosisResult" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
fi

# Check if Finger process is running
if ps -ef | grep -iq "finger"; then
    diagnosisResult="Finger 서비스 프로세스가 실행 중입니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Final check if diagnosisResult is empty, meaning everything is fine
if [ -z "$diagnosisResult" ]; then
    diagnosisResult="Finger 서비스가 비활성화되어 있거나 실행 중이지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

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
