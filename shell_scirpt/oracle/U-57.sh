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
cat $OUTPUT_CSV
