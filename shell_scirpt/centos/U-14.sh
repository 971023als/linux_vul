#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-14"
riskLevel="상"
diagnosisItem="root 홈 PATH '.' 설정 점검"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 점검 파일
#########################################
files=(
"/etc/profile"
"/etc/bashrc"
"/etc/environment"
"/root/.profile"
"/root/.bash_profile"
"/root/.bashrc"
)

취약내용=()
vuln=false

#########################################
# PATH 점검 함수
#########################################
check_path() {
    local file=$1

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | sed 's/#.*//g' | xargs)
        [[ -z "$line" ]] && continue

        if echo "$line" | grep -q "PATH="; then
            path_val=$(echo "$line" | sed -n 's/.*PATH=\(.*\)/\1/p')

            # 맨 앞 .
            if echo "$path_val" | grep -Eq '^\.:'; then
                취약내용+=("$file : PATH 맨앞 '.'")
                vuln=true
            fi

            # 중간 .
            if echo "$path_val" | grep -Eq ':\.:'; then
                취약내용+=("$file : PATH 중간 '.'")
                vuln=true
            fi

            # :: 포함
            if echo "$path_val" | grep -Eq '::'; then
                취약내용+=("$file : PATH '::' 포함")
                vuln=true
            fi
        fi
    done < "$file"
}

#########################################
# 점검 수행
#########################################
for f in "${files[@]}"; do
    [ -f "$f" ] && check_path "$f"
done

#########################################
# 현재 root PATH도 점검
#########################################
current_path=$(echo "$PATH")

if echo "$current_path" | grep -Eq '(^|:)\.(:|$)'; then
    취약내용+=("현재 root PATH 환경변수 '.' 포함")
    vuln=true
fi

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${취약내용[*]}")
else
    diagnosisResult="양호"
    status="root PATH '.' 미포함 또는 안전"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
