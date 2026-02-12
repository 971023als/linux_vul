#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-32"
riskLevel="중"
diagnosisItem="홈 디렉토리 존재 여부 점검"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
취약계정=()
vuln=false

#########################################
# passwd 기준 점검
#########################################
while IFS=: read -r user pass uid gid desc home shell; do

    # 로그인 불가 계정 제외
    if [[ "$shell" == *nologin || "$shell" == *false ]]; then
        continue
    fi

    # 홈이 "/" 이거나 없을 경우
    if [[ "$home" == "/" ]]; then
        취약계정+=("$user(홈디렉토리=/)")
        vuln=true
        continue
    fi

    if [ ! -d "$home" ]; then
        취약계정+=("$user(홈디렉토리 없음:$home)")
        vuln=true
    fi

done < /etc/passwd

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    sample=$(printf '%s\n' "${취약계정[@]}" | head -20)
    status="홈디렉토리 미존재 계정: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="모든 계정 홈디렉토리 정상"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
