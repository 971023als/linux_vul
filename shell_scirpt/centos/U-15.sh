#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-15"
riskLevel="상"
diagnosisItem="파일 및 디렉터리 소유자 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 제외 경로 (성능/운영 보호)
#########################################
exclude_paths=(
"/proc"
"/sys"
"/dev"
"/run"
"/tmp"
"/var/tmp"
"/var/run"
"/mnt"
"/media"
"/lost+found"
)

#########################################
# find 제외옵션 생성
#########################################
prune_expr=""
for p in "${exclude_paths[@]}"; do
    prune_expr+=" -path $p -prune -o"
done

#########################################
# 점검 수행
#########################################
취약목록=()

while IFS= read -r file; do
    취약목록+=("$file")
done < <(eval find / $prune_expr \( -nouser -o -nogroup \) -print 2>/dev/null)

#########################################
# 결과 판정
#########################################
if [ ${#취약목록[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${취약목록[@]}" | head -20)
    status="소유자 없는 파일 존재: $(echo $sample | tr '\n' ' ')"
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
#########################################
cat $OUTPUT_CSV
