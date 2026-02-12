#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-31"
riskLevel="중"
diagnosisItem="홈디렉토리 소유자 및 권한 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
취약내용=()
vuln=false

#########################################
# 홈디렉토리 점검
#########################################
while IFS=: read -r user pass uid gid desc home shell; do

    # 로그인 불가 계정 제외
    if [[ "$shell" == *nologin || "$shell" == *false ]]; then
        continue
    fi

    [ ! -d "$home" ] && continue

    owner=$(stat -c "%U" "$home" 2>/dev/null)
    perm=$(stat -c "%a" "$home" 2>/dev/null)

    # 소유자 확인
    if [[ "$owner" != "$user" ]]; then
        취약내용+=("$home 소유자 불일치:$owner")
        vuln=true
    fi

    # other write 확인
    if [[ $((perm % 10)) -ge 2 ]]; then
        취약내용+=("$home other write:$perm")
        vuln=true
    fi

    # group write 확인
    if [[ $(((perm / 10) % 10)) -ge 2 ]]; then
        취약내용+=("$home group write:$perm")
        vuln=true
    fi

done < /etc/passwd

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    sample=$(printf '%s\n' "${취약내용[@]}" | head -20)
    status=$(echo $sample | tr '\n' ' ')
else
    diagnosisResult="양호"
    status="홈디렉토리 소유자 및 권한 양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
