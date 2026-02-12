#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-27"
riskLevel="상"
diagnosisItem=".rhosts 및 hosts.equiv 사용 금지"
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
# 1. /etc/hosts.equiv 점검
#########################################
file="/etc/hosts.equiv"

if [ -f "$file" ]; then

    owner=$(stat -c "%U" "$file" 2>/dev/null)
    perm=$(stat -c "%a" "$file" 2>/dev/null)

    if [[ "$owner" != "root" ]]; then
        취약내용+=("$file 소유자 비정상:$owner")
        vuln=true
    fi

    if [[ "$perm" -gt 600 ]]; then
        취약내용+=("$file 권한 600 초과:$perm")
        vuln=true
    fi

    if grep -Eq '^\+' "$file"; then
        취약내용+=("$file '+' trust 설정 존재")
        vuln=true
    fi
fi

#########################################
# 2. 사용자 .rhosts 점검
#########################################
while IFS=: read -r user pass uid gid desc home shell; do

    [ ! -d "$home" ] && continue

    rfile="$home/.rhosts"
    [ ! -f "$rfile" ] && continue

    owner=$(stat -c "%U" "$rfile" 2>/dev/null)
    perm=$(stat -c "%a" "$rfile" 2>/dev/null)

    if [[ "$owner" != "$user" && "$owner" != "root" ]]; then
        취약내용+=("$rfile 소유자 비정상:$owner")
        vuln=true
    fi

    if [[ "$perm" -gt 600 ]]; then
        취약내용+=("$rfile 권한 600 초과:$perm")
        vuln=true
    fi

    if grep -Eq '^\+' "$rfile"; then
        취약내용+=("$rfile '+' trust 설정 존재")
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
    status="rhosts/hosts.equiv 설정 양호 또는 미사용"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
