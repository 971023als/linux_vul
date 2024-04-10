#!/bin/bash

# 결과를 저장할 변수 초기화
declare -A results
results[분류]="계정 관리"
results[코드]="U-02"
results[위험도]="상"
results[진단 항목]="패스워드 복잡성 설정"
results[대응방안]="패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능 설정"
results[진단 결과]=""
현황=()

min_length=8
declare -A min_input_requirements=( [lcredit]=-1 [ucredit]=-1 [dcredit]=-1 [ocredit]=-1 )
files_to_check=(
    "/etc/login.defs"
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
    "/etc/security/pwquality.conf"
)
password_settings_found=false

for file_path in "${files_to_check[@]}"; do
    if [[ -f "$file_path" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            line=$(echo "$line" | xargs)
            if [[ ! "$line" =~ ^# && ! -z "$line" ]]; then
                if [[ "$line" =~ PASS_MIN_LEN || "$line" =~ minlen ]]; then
                    password_settings_found=true
                    value=$(echo "$line" | grep -o '[0-9]*')
                    if (( value < min_length )); then
                        현황+=("$file_path에서 설정된 패스워드 최소 길이가 ${min_length}자 미만입니다.")
                    fi
                fi
                for key in "${!min_input_requirements[@]}"; do
                    if [[ "$line" =~ $key ]]; then
                        password_settings_found=true
                        value=$(echo "$line" | sed -n "s/.*$key\s*\(-\?\d\+\).*/\1/p")
                        if (( value < min_input_requirements[$key] )); then
                            현황+=("$file_path에서 $key 설정이 ${min_input_requirements[$key]} 미만입니다.")
                        fi
                    fi
                done
            fi
        done < "$file_path"
    fi
done

if $password_settings_found; then
    if [ ${#현황[@]} -eq 0 ]; then
        results[진단 결과]="양호"
    else
        results[진단 결과]="취약"
    fi
else
    results[진단 결과]="취약"
    현황+=("패스워드 복잡성 설정이 없습니다.")
fi

# 결과 출력
echo "분류: ${results[분류]}"
echo "코드: ${results[코드]}"
echo "위험도: ${results[위험도]}"
echo "진단 항목: ${results[진단 항목]}"
echo "진단 결과: ${results[진단 결과]}"
echo "대응방안: ${results[대응방안]}"
echo "현황:"
for 사항 in "${현황[@]}"; do
    echo "- $사항"
done
