#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="계정 관리"
code="U-10"
riskLevel="상"
diagnosisItem="동일한 UID 금지"
diagnosisResult=""
status=""

# 초기 1줄 기록 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
declare -A uid_map
중복계정=()
현황=()

#########################################
# passwd 점검
#########################################
while IFS=: read -r user pass uid gid desc home shell; do

    # uid_map에 사용자 누적
    if [[ -n "${uid_map[$uid]}" ]]; then
        uid_map[$uid]="${uid_map[$uid]},$user"
    else
        uid_map[$uid]="$user"
    fi

done < /etc/passwd

#########################################
# 중복 UID 탐지
#########################################
for uid in "${!uid_map[@]}"; do
    IFS=',' read -ra users <<< "${uid_map[$uid]}"

    if [[ ${#users[@]} -gt 1 ]]; then
        # root만 여러개면 정상 아님 → 취약
        중복계정+=("UID $uid → ${uid_map[$uid]}")
    fi
done

#########################################
# 결과 판정
#########################################
if [ ${#중복계정[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${중복계정[@]}" | head -10)
    status="중복 UID 존재: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="중복 UID 없음"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
