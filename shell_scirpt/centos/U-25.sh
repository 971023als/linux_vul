#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-25"
riskLevel="상"
diagnosisItem="world writable 파일 점검"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 제외 경로 (오탐/성능 보호)
#########################################
exclude_paths=(
"/proc"
"/sys"
"/dev"
"/run"
"/tmp"
"/var/tmp"
"/var/log"
"/snap"
"/var/lib/docker"
)

#########################################
# prune 생성
#########################################
prune_expr=""
for p in "${exclude_paths[@]}"; do
    prune_expr+=" -path $p -prune -o"
done

#########################################
# 점검 수행
#########################################
취약파일=()

while IFS= read -r file; do
    취약파일+=("$file")
done < <(eval find / $prune_expr -type f -perm -0002 -print 2>/dev/null)

#########################################
# 결과 판정
#########################################
if [ ${#취약파일[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${취약파일[@]}" | head -20)
    status="world writable 파일 존재: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="world writable 파일 없음"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
