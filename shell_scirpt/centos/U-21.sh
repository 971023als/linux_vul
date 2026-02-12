#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-21"
riskLevel="상"
diagnosisItem="/etc/(r)syslog.conf 파일 소유자 및 권한 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 점검 대상
#########################################
files=(
"/etc/syslog.conf"
"/etc/rsyslog.conf"
)

취약내용=()
vuln=false

#########################################
# 점검 수행
#########################################
for file in "${files[@]}"; do

    [ ! -f "$file" ] && continue

    owner=$(stat -c "%U" "$file" 2>/dev/null)
    perm=$(stat -c "%a" "$file" 2>/dev/null)

    # 소유자 확인
    if [[ "$owner" != "root" && "$owner" != "bin" && "$owner" != "sys" ]]; then
        취약내용+=("$file 소유자 비정상:$owner")
        vuln=true
    fi

    # 권한 확인
    if [[ "$perm" -gt 640 ]]; then
        취약내용+=("$file 권한 640 초과:$perm")
        vuln=true
    fi

done

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${취약내용[*]}")
else
    diagnosisResult="양호"
    status="syslog 설정 파일 권한 양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
