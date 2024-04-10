#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-46",
    "위험도": "중",
    "진단 항목": "패스워드 최소 길이 설정",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "패스워드 최소 길이 8자 이상으로 설정"
}' > $results_file

files_to_check=(
    "/etc/login.defs:PASS_MIN_LEN"
    "/etc/pam.d/system-auth:minlen"
    "/etc/pam.d/password-auth:minlen"
    "/etc/security/pwquality.conf:minlen"
)

file_exists_count=0
minlen_file_exists_count=0
no_settings_in_minlen_file=0

for item in "${files_to_check[@]}"; do
    IFS=: read -r file_path setting_key <<< "$item"
    if [ -f "$file_path" ]; then
        file_exists_count=$((file_exists_count + 1))
        if grep -iq "$setting_key" "$file_path"; then
            minlen_file_exists_count=$((minlen_file_exists_count + 1))
            min_length=$(grep -i "$setting_key" "$file_path" | grep -v '^#' | grep -o '[0-9]*' | head -1)
            if [ -n "$min_length" ] && [ "$min_length" -lt 8 ]; then
                jq --arg file_path "$file_path" --arg setting_key "$setting_key" '.진단 결과 = "취약" | .현황 += [$file_path + " 파일에 " + $setting_key + "가 8 미만으로 설정되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
            elif [ -z "$min_length" ]; then
                no_settings_in_minlen_file=$((no_settings_in_minlen_file + 1))
            fi
        else
            no_settings_in_minlen_file=$((no_settings_in_minlen_file + 1))
        fi
    fi
done

if [ "$file_exists_count" -eq 0 ]; then
    jq '.진단 결과 = "취약" | .현황 += ["패스워드 최소 길이를 설정하는 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
elif [ "$minlen_file_exists_count" -eq "$no_settings_in_minlen_file" ]; then
    jq '.진단 결과 = "취약" | .현황 += ["패스워드 최소 길이를 설정한 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
