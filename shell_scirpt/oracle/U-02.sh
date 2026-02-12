#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="계정 관리"
code="U-02"
riskLevel="상"
diagnosisItem="패스워드 복잡성 설정"
diagnosisResult=""
status=""

#########################################
# 기준값
#########################################
min_length=8
declare -A min_input_requirements=( [lcredit]=-1 [ucredit]=-1 [dcredit]=-1 [ocredit]=-1 )

files_to_check=(
    "/etc/login.defs"
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
    "/etc/security/pwquality.conf"
)

password_settings_found=false
현황=()

#########################################
# 파일 점검 시작
#########################################
for file_path in "${files_to_check[@]}"; do
    [[ ! -f "$file_path" ]] && continue

    while IFS= read -r line || [[ -n "$line" ]]; do
        # 주석 제거
        line=$(echo "$line" | sed 's/#.*//g' | xargs)
        [[ -z "$line" ]] && continue

        #################################
        # 최소 길이
        #################################
        if echo "$line" | grep -Eq "(PASS_MIN_LEN|minlen)"; then
            password_settings_found=true
            value=$(echo "$line" | grep -oE '[0-9]+' | head -1)

            if [[ -z "$value" ]]; then
                현황+=("$file_path 최소길이 설정값 없음")
            elif (( value < min_length )); then
                현황+=("$file_path 최소길이 ${value} (권장:${min_length} 이상)")
            fi
        fi

        #################################
        # 복잡도 credit 체크
        #################################
        for key in "${!min_input_requirements[@]}"; do
            if echo "$line" | grep -q "$key"; then
                password_settings_found=true
                value=$(echo "$line" | sed -n "s/.*$key[[:space:]]*=[[:space:]]*\(-\?[0-9]\+\).*/\1/p")

                if [[ -z "$value" ]]; then
                    현황+=("$file_path $key 값 확인불가")
                else
                    # credit 값은 -1 이하이면 1개 이상 요구
                    if (( value > -1 )); then
                        현황+=("$file_path $key 설정 미흡 (현재:$value 권장:-1)")
                    fi
                fi
            fi
        done

    done < "$file_path"
done

# 결과 판정

if $password_settings_found; then
    if [ ${#현황[@]} -eq 0 ]; then
        diagnosisResult="양호"
        status="패스워드 복잡성 정책 적정"
    else
        diagnosisResult="취약"
        status=$(IFS=' | '; echo "${현황[*]}")
    fi
else
    diagnosisResult="취약"
    status="패스워드 복잡성 설정 없음"
fi


# CSV 기록

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
