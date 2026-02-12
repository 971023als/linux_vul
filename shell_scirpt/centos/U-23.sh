#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-23"
riskLevel="상"
diagnosisItem="SUID SGID Sticky bit 설정 파일 점검"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 제외 경로 (성능/오탐 방지)
#########################################
exclude_paths=(
"/proc"
"/sys"
"/dev"
"/run"
"/tmp"
"/var/tmp"
"/snap"
"/var/lib/docker"
)

#########################################
# 정상 SUID 화이트리스트
#########################################
whitelist=(
"/usr/bin/passwd"
"/usr/bin/su"
"/usr/bin/chage"
"/usr/bin/gpasswd"
"/usr/bin/newgrp"
"/usr/bin/mount"
"/usr/bin/umount"
"/usr/bin/crontab"
)

#########################################
# prune 옵션 생성
#########################################
prune_expr=""
for p in "${exclude_paths[@]}"; do
    prune_expr+=" -path $p -prune -o"
done

#########################################
# 점검 수행
#########################################
의심파일=()

while IFS= read -r file; do

    skip=false
    for w in "${whitelist[@]}"; do
        if [[ "$file" == "$w" ]]; then
            skip=true
            break
        fi
    done

    if ! $skip; then
        의심파일+=("$file")
    fi

done < <(eval find / $prune_expr -type f \( -perm -4000 -o -perm -2000 \) -print 2>/dev/null)

#########################################
# 결과 판정
#########################################
if [ ${#의심파일[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${의심파일[@]}" | head -20)
    status="불필요 SUID/SGID 의심파일: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="불필요 SUID/SGID 파일 없음"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
