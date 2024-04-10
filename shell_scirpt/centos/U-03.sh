#!/bin/bash

# 변수 초기화
분류="계정 관리"
코드="U-03"
위험도="상"
진단_항목="계정 잠금 임계값 설정"
대응방안="계정 잠금 임계값을 10회 이하로 설정"
진단_결과=""
현황=()

deny_files_checked=false
account_lockout_threshold_set=false
files_to_check=(
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
)
deny_modules=("pam_tally2.so" "pam_faillock.so")

for file_path in "${files_to_check[@]}"; do
    if [ -f "$file_path" ]; then
        deny_files_checked=true
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | xargs) # Trim
            if [[ ! "$line" =~ ^# && "$line" =~ deny ]]; then
                for deny_module in "${deny_modules[@]}"; do
                    if [[ "$line" =~ $deny_module ]]; then
                        deny_value=$(echo "$line" | grep -oP 'deny=\K\d+')
                        if [[ "$deny_value" -le 10 ]]; then
                            account_lockout_threshold_set=true
                        else
                            현황+=("$file_path에서 설정된 계정 잠금 임계값이 10회를 초과합니다.")
                        fi
                    fi
                done
            fi
        done < "$file_path"
    fi
done

if ! $deny_files_checked; then
    현황+=("계정 잠금 임계값을 설정하는 파일을 찾을 수 없습니다.")
    진단_결과="취약"
elif ! $account_lockout_threshold_set; then
    현황+=("적절한 계정 잠금 임계값 설정이 없습니다.")
    진단_결과="취약"
else
    현황+=("계정 잠금 임계값이 적절히 설정되었습니다.")
    진단_결과="양호"
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
echo "현황:"
for 사항 in "${현황[@]}"; do
    echo "- $사항"
done
