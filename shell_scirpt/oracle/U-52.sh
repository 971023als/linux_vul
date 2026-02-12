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
cat $OUTPUT_CSV
