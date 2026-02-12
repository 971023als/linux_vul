#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="계정 관리"
code="U-12"
riskLevel="중"
diagnosisItem="세션 종료 시간 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 기준값
#########################################
limit_tmout=600
limit_csh=10

files=(
"/etc/profile"
"/etc/bashrc"
"/etc/csh.cshrc"
"/etc/csh.login"
)

설정확인=false
취약내용=()

#########################################
# 점검 시작
#########################################
for file in "${files[@]}"; do
    [ ! -f "$file" ] && continue

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | sed 's/#.*//g' | xargs)
        [[ -z "$line" ]] && continue

        # TMOUT 점검
        if echo "$line" | grep -q "TMOUT"; then
            설정확인=true
            val=$(echo "$line" | sed -n 's/.*TMOUT=\([0-9]\+\).*/\1/p')

            if [[ -n "$val" && $val -gt $limit_tmout ]]; then
                취약내용+=("$file TMOUT=$val(600초 초과)")
            fi
        fi

        # csh autologout 점검
        if echo "$line" | grep -qi "autologout"; then
            설정확인=true
            val=$(echo "$line" | sed -n 's/.*autologout=\([0-9]\+\).*/\1/p')

            if [[ -n "$val" && $val -gt $limit_csh ]]; then
                취약내용+=("$file autologout=$val(10분 초과)")
            fi
        fi

    done < "$file"
done

#########################################
# 결과 판정
#########################################
if ! $설정확인; then
    diagnosisResult="취약"
    status="Session Timeout 설정 없음"
elif [ ${#취약내용[@]} -gt 0 ]; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${취약내용[*]}")
else
    diagnosisResult="양호"
    status="Session Timeout 600초 이하 설정"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
