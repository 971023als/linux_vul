#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-06"
riskLevel="상"
diagnosisItem="파일 및 디렉터리 소유자 설정"
diagnosisResult=""
status=""

# 초기 1줄 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
no_owner_files=()
scan_paths=("/" )
exclude_paths=(
"/proc/*"
"/sys/*"
"/dev/*"
"/run/*"
"/var/run/*"
"/tmp/*"
"/var/tmp/*"
"/mnt/*"
"/media/*"
)

#########################################
# find 제외옵션 생성
#########################################
prune_expr=""
for p in "${exclude_paths[@]}"; do
    prune_expr+=" -path $p -prune -o"
done

#########################################
# 점검 시작
#########################################
while IFS= read -r -d '' file; do
    no_owner_files+=("$file")
done < <(eval find / $prune_expr -nouser -o -nogroup -print0 2>/dev/null)

#########################################
# 결과 판정
#########################################
if [ ${#no_owner_files[@]} -gt 0 ]; then
    diagnosisResult="취약"

    # 최대 20개만 출력 (보고서용)
    limited=$(printf '%s\n' "${no_owner_files[@]}" | head -20)
    status="소유자 없는 파일 존재 (일부): $(echo $limited | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="소유자 없는 파일 없음"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력

cat $OUTPUT_CSV
