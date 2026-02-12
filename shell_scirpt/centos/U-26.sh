#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-26"
riskLevel="상"
diagnosisItem="/dev 존재하지 않는 device 파일 점검"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 예외 디렉터리
#########################################
exclude_dirs=(
"/dev/pts"
"/dev/shm"
"/dev/mqueue"
)

의심파일=()
vuln=false

#########################################
# 점검 수행
#########################################
while IFS= read -r file; do

    skip=false
    for ex in "${exclude_dirs[@]}"; do
        if [[ "$file" == "$ex"* ]]; then
            skip=true
            break
        fi
    done

    $skip && continue

    의심파일+=("$file")
    vuln=true

done < <(find /dev -type f 2>/dev/null)

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    sample=$(printf '%s\n' "${의심파일[@]}" | head -20)
    status="비정상 device 파일 의심: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="/dev 내 비정상 파일 없음"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
