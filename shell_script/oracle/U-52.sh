#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-52"
riskLevel="중"
diagnosisItem="동일한 UID 금지"
service="Account Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

min_regular_user_uid=1000
declare -A uid_counts
duplicate_uids=()

if [ -f "/etc/passwd" ]; then
    # Extract UIDs and check for duplicates for regular user UIDs (>=1000)
    while IFS=: read -r _ _ uid _; do
        if [ "$uid" -ge "$min_regular_user_uid" ]; then
            uid_counts["$uid"]=$((uid_counts["$uid"]+1))
        fi
    done < <(grep -v '^#' /etc/passwd)

    for uid in "${!uid_counts[@]}"; do
        if [ "${uid_counts[$uid]}" -gt 1 ]; then
            duplicate_uids+=("UID $uid (${uid_counts[$uid]}x)")
        fi
    done

    if [ ${#duplicate_uids[@]} -gt 0 ]; then
        diagnosisResult="동일한 UID로 설정된 사용자 계정이 존재합니다: ${duplicate_uids[*]}"
        status="취약"
        echo "WARN: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    else
        diagnosisResult="동일한 UID를 공유하는 사용자 계정이 없습니다."
        status="양호"
        echo "OK: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="/etc/passwd 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult"
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
