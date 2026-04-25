#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-30"
riskLevel="상"
diagnosisItem="Sendmail 버전 점검"
solution="Sendmail 버전을 최신 버전으로 유지"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

latest_version="8.17.1"  # 최신 Sendmail 버전 예시

# Check Sendmail version on RPM-based systems
sendmail_version=$(rpm -qa | grep 'sendmail' | grep -oP 'sendmail-\K(\d+\.\d+\.\d+)')

# Determine the diagnosis result
if [[ $sendmail_version ]]; then
    if [[ $sendmail_version == $latest_version* ]]; then
        diagnosisResult="Sendmail 버전이 최신 버전(${latest_version})입니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Sendmail 버전이 최신 버전(${latest_version})이 아닙니다. 현재 버전: ${sendmail_version}"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="Sendmail이 설치되어 있지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

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
