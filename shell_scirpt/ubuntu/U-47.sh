#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-47",
    "위험도": "중",
    "진단 항목": "패스워드 최대 사용기간 설정",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "패스워드 최대 사용기간 90일 이하로 설정"
}' > $results_file

login_defs_path="/etc/login.defs"

if [ -f "$login_defs_path" ]; then
    while IFS= read -r line; do
        if echo "$line" | grep -q "PASS_MAX_DAYS" && ! echo "$line" | grep -q "^#"; then
            max_days=$(echo "$line" | awk '{print $2}')
            if [ "$max_days" -gt 90 ]; then
                jq --arg max_days "$max_days" '.진단 결과 = "취약" | .현황 += ["/etc/login.defs 파일에 패스워드 최대 사용 기간이 90일을 초과하여 " + $max_days + "일로 설정되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
            fi
            break
        fi
    done < "$login_defs_path"
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/login.defs 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
