#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-17"
riskLevel="상"
diagnosisItem="시스템 시작 스크립트 권한 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 점검 대상 경로
#########################################
paths=(
"/etc/rc.d"
"/etc/init.d"
"/etc/systemd/system"
"/usr/lib/systemd/system"
)

취약파일=()
vuln=false

#########################################
# 점검 수행
#########################################
for p in "${paths[@]}"; do
    [ ! -d "$p" ] && continue

    while IFS= read -r file; do

        owner=$(stat -c "%U" "$file" 2>/dev/null)
        perm=$(stat -c "%a" "$file" 2>/dev/null)

        # root 소유 아님
        if [[ "$owner" != "root" ]]; then
            취약파일+=("$file (owner:$owner)")
            vuln=true
            continue
        fi

        # others write
        if [[ $((perm % 10)) -ge 2 ]]; then
            취약파일+=("$file (others write:$perm)")
            vuln=true
            continue
        fi

        # group write
        if [[ $(((perm / 10) % 10)) -ge 2 ]]; then
            취약파일+=("$file (group write:$perm)")
            vuln=true
            continue
        fi

    done < <(find "$p" -type f 2>/dev/null)

done

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${취약파일[@]}" | head -15)
    status="시작스크립트 권한 취약: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="시스템 시작 스크립트 권한 양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
