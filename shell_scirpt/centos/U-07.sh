#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="계정 관리"
code="U-07"
riskLevel="상"
diagnosisItem="불필요한 계정 제거"
diagnosisResult=""
status=""

# 초기 1줄 기록 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 기준
#########################################
unused_days=90
today_epoch=$(date +%s)

불필요계정=()
현황=()

#########################################
# 계정 점검
#########################################
while IFS=: read -r user pass uid gid desc home shell; do

    # 시스템 계정 skip
    if [[ $uid -lt 1000 ]]; then
        continue
    fi

    # 로그인 불가 계정 skip
    if [[ "$shell" == *nologin || "$shell" == *false ]]; then
        continue
    fi

    # lastlog 확인
    lastlog_info=$(lastlog -u "$user" 2>/dev/null | tail -1)

    if echo "$lastlog_info" | grep -q "Never logged in"; then
        불필요계정+=("$user(로그인 이력 없음)")
        continue
    fi

    last_date=$(echo "$lastlog_info" | awk '{print $4,$5,$6,$7,$8}')
    last_epoch=$(date -d "$last_date" +%s 2>/dev/null)

    if [[ -n "$last_epoch" ]]; then
        diff_days=$(( (today_epoch - last_epoch) / 86400 ))

        if (( diff_days > unused_days )); then
            불필요계정+=("$user(${diff_days}일 미사용)")
        fi
    fi

done < /etc/passwd

#########################################
# 결과 판정
#########################################
if [ ${#불필요계정[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${불필요계정[@]}" | head -10)
    status="장기 미사용 계정 존재: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="장기 미사용 계정 없음"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
cat $OUTPUT_CSV
