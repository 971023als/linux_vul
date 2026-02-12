#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="계정 관리"
code="U-13"
riskLevel="상"
diagnosisItem="비밀번호 암호화 알고리즘 사용"
diagnosisResult=""
status=""

# 초기 1줄 기록 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
shadow_file="/etc/shadow"
login_defs="/etc/login.defs"

취약계정=()
설정취약=false
현황=()

#########################################
# 1. shadow 암호화 방식 확인
#########################################
if [ -f "$shadow_file" ]; then
    while IFS=: read -r user hash rest; do

        [[ -z "$hash" ]] && continue
        [[ "$hash" == "!"* ]] && continue
        [[ "$hash" == "*"* ]] && continue

        if echo "$hash" | grep -q '^\$1\$'; then
            취약계정+=("$user(MD5)")
        elif echo "$hash" | grep -q '^\$2'; then
            취약계정+=("$user(Blowfish)")
        fi

    done < "$shadow_file"
else
    설정취약=true
    현황+=("/etc/shadow 파일 없음")
fi

#########################################
# 2. login.defs 설정 확인
#########################################
if [ -f "$login_defs" ]; then
    enc=$(grep -i "^ENCRYPT_METHOD" "$login_defs" | awk '{print $2}')

    if [[ "$enc" != "SHA512" && "$enc" != "SHA256" ]]; then
        설정취약=true
        현황+=("ENCRYPT_METHOD 설정 취약: $enc")
    fi
else
    설정취약=true
    현황+=("/etc/login.defs 없음")
fi

#########################################
# 결과 판정
#########################################
if [ ${#취약계정[@]} -gt 0 ]; then
    diagnosisResult="취약"
    sample=$(printf '%s\n' "${취약계정[@]}" | head -10)
    status="취약 알고리즘 계정: $(echo $sample | tr '\n' ' ')"

elif $설정취약; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")

else
    diagnosisResult="양호"
    status="SHA-2 이상 암호화 알고리즘 사용"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
