#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-05"
riskLevel="상"
diagnosisItem="root홈, 패스 디렉터리 권한 및 패스 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
global_files=(
    "/etc/profile"
    "/etc/.login"
    "/etc/csh.cshrc"
    "/etc/csh.login"
    "/etc/environment"
)

user_files=(
    ".profile"
    ".cshrc"
    ".login"
    ".kshrc"
    ".bash_profile"
    ".bashrc"
    ".bash_login"
)

현황=()
vuln=false

#########################################
# 1. root 홈 디렉터리 권한 점검
#########################################
root_home=$(awk -F: '$1=="root"{print $6}' /etc/passwd)

if [ -d "$root_home" ]; then
    perm=$(stat -c "%a" "$root_home" 2>/dev/null)

    if [[ "$perm" -gt 750 ]]; then
        현황+=("root 홈 디렉터리 권한 취약 ($root_home : $perm)")
        vuln=true
    fi
else
    현황+=("root 홈 디렉터리 없음")
    vuln=true
fi

#########################################
# PATH 점검 함수
#########################################
check_path_file() {
    local file=$1
    local label=$2

    if [ -f "$file" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | sed 's/#.*//g')

            if echo "$line" | grep -Eq 'PATH='; then
                path_val=$(echo "$line" | sed -n 's/.*PATH=\(.*\)/\1/p')

                if echo "$path_val" | grep -Eq '(^|:)\.(:|$)'; then
                    현황+=("$label $file : PATH에 '.' 포함")
                    vuln=true
                fi

                if echo "$path_val" | grep -Eq '::'; then
                    현황+=("$label $file : PATH에 '::' 포함")
                    vuln=true
                fi
            fi
        done < "$file"
    fi
}

#########################################
# 2. 글로벌 환경파일 점검
#########################################
for file in "${global_files[@]}"; do
    check_path_file "$file" "[global]"
done

#########################################
# 3. 사용자 환경파일 점검
#########################################
while IFS=: read -r username _ uid _ _ homedir shell; do

    # 시스템계정/로그인불가 skip
    if [[ "$shell" == *"nologin"* || "$shell" == *"false"* ]]; then
        continue
    fi

    [ ! -d "$homedir" ] && continue

    for uf in "${user_files[@]}"; do
        file_path="$homedir/$uf"
        check_path_file "$file_path" "[$username]"
    done

done < /etc/passwd

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
else
    diagnosisResult="양호"
    현황+=("root홈 및 PATH 설정 양호")
fi

status=$(IFS=' | '; echo "${현황[*]}")

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
