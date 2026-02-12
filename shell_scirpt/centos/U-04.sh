#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 관리"
code="U-04"
riskLevel="상"
diagnosisItem="패스워드 파일 보호"
diagnosisResult=""
status=""

# Write initial values to CSV (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
passwd_file="/etc/passwd"
shadow_file="/etc/shadow"
shadow_used=true
현황=()

#########################################
# 1. /etc/passwd shadow 사용 여부
#########################################
if [ -f "$passwd_file" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        IFS=':' read -r user pass rest <<< "$line"

        # x가 아니면 shadow 미사용 가능
        if [[ "$pass" != "x" ]]; then
            shadow_used=false
            현황+=("shadow 미사용 계정 발견: $user")
            break
        fi
    done < "$passwd_file"
else
    shadow_used=false
    현황+=("/etc/passwd 파일 없음")
fi

#########################################
# 2. /etc/shadow 존재 및 권한
#########################################
if [ ! -f "$shadow_file" ]; then
    shadow_used=false
    현황+=("/etc/shadow 파일 없음")
else
    # 권한 확인
    perm=$(stat -c "%a" "$shadow_file" 2>/dev/null)

    if [[ "$perm" != "400" && "$perm" != "000" && "$perm" != "600" ]]; then
        shadow_used=false
        현황+=("/etc/shadow 권한 취약: $perm")
    else
        현황+=("/etc/shadow 권한 정상: $perm")
    fi
fi

#########################################
# 결과 판정
#########################################
if $shadow_used; then
    diagnosisResult="양호"
    현황+=("shadow 패스워드 사용 및 보호 설정 정상")
else
    diagnosisResult="취약"
    현황+=("shadow 패스워드 보호 설정 미흡")
fi

status=$(IFS=' | '; echo "${현황[*]}")

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
