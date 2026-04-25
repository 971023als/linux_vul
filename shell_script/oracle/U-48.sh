#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-48"
riskLevel="중"
diagnosisItem="패스워드 최소 사용기간 설정"
service="Account Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

login_defs_path="/etc/login.defs"
result="양호"

if [ -f "$login_defs_path" ]; then
    while IFS= read -r line; do
        if echo "$line" | grep -q "PASS_MIN_DAYS" && ! echo "$line" | grep -q "^#"; then
            min_days=$(echo "$line" | awk '{print $2}')
            if [ "$min_days" -lt 1 ]; then
                result="취약"
                diagnosisResult="/etc/login.defs 파일에 패스워드 최소 사용 기간이 1일 미만으로 설정되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult"
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
            break
        fi
    done < "$login_defs_path"
else
    result="취약"
    diagnosisResult="/etc/login.defs 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

if [ "$result" = "양호" ]; then
    diagnosisResult="패스워드 최소 사용 기간이 적절하게 설정되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Output CSV

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
