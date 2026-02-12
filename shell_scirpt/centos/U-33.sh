#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-33"
riskLevel="하"
diagnosisItem="숨겨진 파일 및 디렉토리 점검"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 제외 경로 (성능/정상파일)
#########################################
exclude_paths=(
"/proc"
"/sys"
"/dev"
"/run"
"/tmp"
"/var/tmp"
"/var/lib/docker"
"/snap"
)

#########################################
# 정상 숨김파일 패턴
#########################################
safe_patterns=(
".bashrc"
".bash_profile"
".profile"
".bash_logout"
".cache"
".config"
".ssh"
)

의심파일=()

#########################################
# prune 생성
#########################################
prune_expr=""
for p in "${exclude_paths[@]}"; do
    prune_expr+=" -path $p -prune -o"
done

#########################################
# 숨김파일 점검
#########################################
while IFS= read -r file; do

    base=$(basename "$file")
    safe=false

    for s in "${safe_patterns[@]}"; do
        if [[ "$base" == "$s" ]]; then
            safe=true
            break
        fi
    done

    if ! $safe; then
        의심파일+=("$file")
    fi

done < <(eval find / $prune_expr -name ".*" -type f -print 2>/dev/null)

#########################################
# 결과 판정
#########################################
if [ ${#의심파일[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${의심파일[@]}" | head -20)
    status="의심 숨김파일 존재: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="의심 숨김파일 없음"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
