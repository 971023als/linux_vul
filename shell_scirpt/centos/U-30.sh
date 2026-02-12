#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-30"
riskLevel="중"
diagnosisItem="UMASK 설정 관리"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 점검 파일 목록
#########################################
files=(
"/etc/profile"
"/etc/login.defs"
"/etc/bashrc"
"/etc/csh.cshrc"
"/etc/default/login"
)

vuln=false
설정확인=false
취약내용=()

#########################################
# UMASK 파싱 함수
#########################################
check_umask() {
    local file=$1

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | sed 's/#.*//g' | xargs)
        [[ -z "$line" ]] && continue

        if echo "$line" | grep -Ei 'umask|UMASK' >/dev/null; then
            설정확인=true

            val=$(echo "$line" | grep -oE '[0-7]{3}' | head -1)

            if [[ -n "$val" ]]; then
                if (( 8#$val < 022 )); then
                    취약내용+=("$file UMASK=$val (022 미만)")
                    vuln=true
                fi
            fi
        fi

    done < "$file"
}

#########################################
# 점검 수행
#########################################
for f in "${files[@]}"; do
    [ -f "$f" ] && check_umask "$f"
done

#########################################
# 결과 판정
#########################################
if ! $설정확인; then
    diagnosisResult="취약"
    status="UMASK 설정 없음"
elif $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${취약내용[*]}")
else
    diagnosisResult="양호"
    status="UMASK 022 이상 설정"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
