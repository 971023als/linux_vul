#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 관리"
code="U-03"
riskLevel="상"
diagnosisItem="계정 잠금 임계값 설정"
diagnosisResult=""
status=""

# Write initial values to CSV (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
deny_files_checked=false
account_lockout_threshold_set=false

files_to_check=(
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
)

deny_modules=("pam_tally2.so" "pam_faillock.so")
현황=()

#########################################
# 점검 시작
#########################################
for file_path in "${files_to_check[@]}"; do
    if [ -f "$file_path" ]; then
        deny_files_checked=true

        while IFS= read -r line || [ -n "$line" ]; do
            # 주석 제거 + trim
            line=$(echo "$line" | sed 's/#.*//g' | xargs)
            [[ -z "$line" ]] && continue

            for deny_module in "${deny_modules[@]}"; do
                if echo "$line" | grep -q "$deny_module"; then

                    # deny 값 추출 (grep -P 제거 → 범용)
                    deny_value=$(echo "$line" | sed -n 's/.*deny=\([0-9]\+\).*/\1/p')

                    if [[ -z "$deny_value" ]]; then
                        현황+=("$file_path : deny 값 확인불가")
                        continue
                    fi

                    if (( deny_value <= 10 )); then
                        account_lockout_threshold_set=true
                    else
                        현황+=("$file_path : deny=$deny_value (권장 10 이하)")
                    fi
                fi
            done

        done < "$file_path"
    fi
done

#########################################
# 결과 판정
#########################################
if ! $deny_files_checked; then
    현황+=("PAM 설정 파일(system-auth/password-auth) 없음")
    diagnosisResult="취약"

elif ! $account_lockout_threshold_set; then
    현황+=("계정 잠금 임계값 10회 이하 설정 없음")
    diagnosisResult="취약"

else
    현황+=("계정 잠금 임계값 10회 이하 설정 확인")
    diagnosisResult="양호"
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
