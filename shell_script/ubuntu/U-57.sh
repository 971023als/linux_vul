#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-57"
riskLevel="중"
diagnosisItem="홈디렉토리 소유자 및 권한 설정"
service="File and Directory Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Get all user entries and iterate
getent passwd | while IFS=: read -r username _ uid _ _ homedir _; do
    # Skip system users by UID
    if [ "$uid" -ge 1000 ]; then
        if [ -d "$homedir" ]; then
            dir_owner_uid=$(stat -c "%u" "$homedir")
            if [ "$dir_owner_uid" != "$uid" ]; then
                diagnosisResult="${homedir} 홈 디렉터리의 소유자가 ${username}이(가) 아닙니다."
                status="취약"
                echo "WARN: $diagnosisResult"
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
            if [ "$(stat -c "%A" "$homedir" | cut -c8)" == "w" ]; then
                diagnosisResult="${homedir} 홈 디렉터리에 타 사용자(other) 쓰기 권한이 설정되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult"
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
        else
            diagnosisResult="${homedir} 홈 디렉터리가 존재하지 않습니다."
            status="취약"
            echo "WARN: $diagnosisResult"
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    fi
done

if [ "$status" = "양호" ]; then
    diagnosisResult="모든 홈 디렉터리가 적절히 설정되었습니다."
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
