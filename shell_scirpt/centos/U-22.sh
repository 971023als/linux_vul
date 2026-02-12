#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-22"
riskLevel="상"
diagnosisItem="/etc/services 파일 소유자 및 권한 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 점검 파일
#########################################
file="/etc/services"
취약내용=()
vuln=false

#########################################
# 파일 존재 확인
#########################################
if [ ! -f "$file" ]; then
    diagnosisResult="취약"
    status="/etc/services 파일 없음"

else
    #####################################
    # 소유자 및 권한 확인
    #####################################
    owner=$(stat -c "%U" "$file" 2>/dev/null)
    perm=$(stat -c "%a" "$file" 2>/dev/null)

    # 소유자 확인
    if [[ "$owner" != "root" && "$owner" != "bin" && "$owner" != "sys" ]]; then
        취약내용+=("소유자 비정상:$owner")
        vuln=true
    fi

    # 권한 확인
    if [[ "$perm" -gt 644 ]]; then
        취약내용+=("권한 644 초과:$perm")
        vuln=true
    fi

    #####################################
    # 결과 판정
    #####################################
    if $vuln; then
        diagnosisResult="취약"
        status=$(IFS=' | '; echo "${취약내용[*]}")
    else
        diagnosisResult="양호"
        status="/etc/services 소유자 및 권한 양호"
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
