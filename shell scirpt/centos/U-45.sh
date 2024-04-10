#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-45",
    "위험도": "하",
    "진단 항목": "root 계정 su 제한",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "su 명령어 사용 특정 그룹 제한"
}' > $results_file

pam_su_path="/etc/pam.d/su"

if [ -f "$pam_su_path" ]; then
    pam_contents=$(cat "$pam_su_path")
    if echo "$pam_contents" | grep -q "pam_rootok.so"; then
        if ! echo "$pam_contents" | grep -q "pam_wheel.so" || ! echo "$pam_contents" | grep -q "auth required pam_wheel.so use_uid"; then
            result="취약"
            status="/etc/pam.d/su 파일에 pam_wheel.so 모듈 설정이 적절히 구성되지 않았습니다."
        fi
    else
        result="취약"
        status="/etc/pam.d/su 파일에서 pam_rootok.so 모듈이 누락되었습니다."
    fi
else
    result="취약"
    status="/etc/pam.d/su 파일이 존재하지 않습니다."
fi

if [ "$result" = "취약" ]; then
    jq --arg status "$status" '.진단 결과 = "취약" | .현황 += [$status]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    jq '.현황 += ["/etc/pam.d/su 파일에 대한 설정이 적절하게 구성되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
