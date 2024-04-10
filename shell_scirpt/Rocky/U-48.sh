#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-48",
    "위험도": "중",
    "진단 항목": "패스워드 최소 사용기간 설정",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "패스워드 최소 사용기간 1일 이상으로 설정"
}' > $results_file

login_defs_path="/etc/login.defs"

if [ -f "$login_defs_path" ]; then
    while IFS= read -r line; do
        if echo "$line" | grep -q "PASS_MIN_DAYS" && ! echo "$line" | grep -q "^#"; then
            min_days=$(echo "$line" | awk '{print $2}')
            if [ "$min_days" -lt 1 ]; then
                jq --arg min_days "$min_days" '.진단 결과 = "취약" | .현황 += ["/etc/login.defs 파일에 패스워드 최소 사용 기간이 1일 미만으로 설정되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
            fi
            break
        fi
    done < "$login_defs_path"
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/login.defs 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
