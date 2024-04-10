#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-44",
    "위험도": "중",
    "진단 항목": "root 이외의 UID가 '\''0'\'' 금지",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "root 계정 외 UID 0 사용 금지"
}' > $results_file

# /etc/passwd 파일에서 UID가 '0'이고 사용자 이름이 'root'가 아닌 계정 검사
vulnerable=false
while IFS=: read -r username _ userid _; do
    if [ "$userid" == "0" ] && [ "$username" != "root" ]; then
        vulnerable=true
        echo "취약: root 계정과 동일한 UID(0)를 갖는 계정이 존재합니다: $username"
        jq --arg username "$username" '.진단 결과 = "취약" | .현황 += ["root 계정과 동일한 UID(0)를 갖는 계정이 존재합니다: " + $username]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
        break
    fi
done < /etc/passwd

if [ "$vulnerable" = false ]; then
    jq '.현황 += ["root 계정 외에 UID 0을 갖는 계정이 존재하지 않습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
