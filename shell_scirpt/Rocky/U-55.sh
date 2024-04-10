#!/bin/bash

# Initialize the results file
results_file="results.json"
echo '{
    "분류": "파일 및 디렉토리 관리",
    "코드": "U-55",
    "위험도": "하",
    "진단 항목": "hosts.lpd 파일 소유자 및 권한 설정",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "hosts.lpd 파일이 없거나, root 소유 및 권한 600 설정"
}' > $results_file

hosts_lpd_path="/etc/hosts.lpd"

if [ -e "$hosts_lpd_path" ]; then
    file_owner=$(stat -c "%u" "$hosts_lpd_path")
    file_mode=$(stat -c "%a" "$hosts_lpd_path")

    if [ "$file_owner" != "0" ] || [ "$file_mode" != "600" ]; then
        result_status="취약"
        owner_status="root 소유가 아님"
        permission_status="권한이 600이 아님"
        [ "$file_owner" == "0" ] && owner_status="소유자 상태는 양호함"
        [ "$file_mode" == "600" ] && permission_status="권한 상태는 양호함"
        jq --arg status "$owner_status, $permission_status" '.진단 결과 = "취약" | .현황 += ["/etc/hosts.lpd 파일 상태: " + $status]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
else
    jq '.현황 += ["/etc/hosts.lpd 파일이 존재하지 않으므로 검사 대상이 아닙니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# Print the results
cat $results_file
