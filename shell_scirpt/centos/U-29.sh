#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-29"
riskLevel="중"
diagnosisItem="hosts.lpd 파일 소유자 및 권한 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 점검 파일
#########################################
file="/etc/hosts.lpd"
취약내용=()
vuln=false

#########################################
# 파일 존재 여부
#########################################
if [ ! -f "$file" ]; then
    diagnosisResult="양호"
    status="/etc/hosts.lpd 파일 미존재 (양호)"

else
    owner=$(stat -c "%U" "$file" 2>/dev/null)
    perm=$(stat -c "%a" "$file" 2>/dev/null)

    if [[ "$owner" != "root" ]]; then
        취약내용+=("소유자 root 아님:$owner")
        vuln=true
    fi

    if [[ "$perm" -gt 600 ]]; then
        취약내용+=("권한 600 초과:$perm")
        vuln=true
    fi

    if $vuln; then
        diagnosisResult="취약"
        status=$(IFS=' | '; echo "${취약내용[*]}")
    else
        diagnosisResult="양호"
        status="hosts.lpd 권한 및 소유자 정상"
    fi
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
