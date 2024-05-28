#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-51"
riskLevel="하"
diagnosisItem="계정이 존재하지 않는 GID 금지"
service="Account Management"
diagnosisResult="양호"
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

if [ -f "/etc/group" ] && [ -f "/etc/passwd" ]; then
    # Extract GIDs in use from /etc/passwd
    gids_in_use=$(cut -d: -f4 /etc/passwd | sort -u)

    unnecessary_groups=()
    while IFS=: read -r group_name _ gid members; do
        # Check if GID is >= 500 and not in use or group is empty
        if [ "$gid" -ge 500 ] && [[ ! " $gids_in_use " =~ " $gid " ]] && [ -z "$members" ]; then
            unnecessary_groups+=("$group_name")
        fi
    done < "/etc/group"

    if [ ${#unnecessary_groups[@]} -gt 0 ]; then
        diagnosisResult="계정이 없는 불필요한 그룹이 존재합니다: ${unnecessary_groups[*]}"
        status="취약"
        echo "WARN: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    else
        diagnosisResult="계정이 없는 불필요한 그룹이 없습니다."
        status="양호"
        echo "OK: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="/etc/group 또는 /etc/passwd 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Output CSV
cat $OUTPUT_CSV
