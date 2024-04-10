#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "서비스 관리",
    "코드": "U-40",
    "위험도": "상",
    "진단 항목": "웹서비스 파일 업로드 및 다운로드 제한",
    "진단 결과": null,
    "현황": [],
    "대응방안": "파일 업로드 및 다운로드 제한 설정"
}' > $results_file

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
found_vulnerability=false

for conf_file in "${webconf_files[@]}"; do
    find_output=$(find / -name $conf_file -type f 2>/dev/null)
    for file_path in $find_output; do
        if [[ -n "$file_path" ]]; then
            content=$(cat "$file_path")
            if ! grep -q "LimitRequestBody" "$file_path"; then
                found_vulnerability=true
                jq --arg path "$file_path" '.현황 += [$path + " 파일에 파일 업로드 및 다운로드 제한 설정이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
                break 2
            fi
        fi
    done
done

if [ "$found_vulnerability" = false ]; then
    jq '.진단 결과 = "양호" | .현황 += ["웹서비스 설정 파일에서 파일 업로드 및 다운로드가 적절히 제한되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    jq '.진단 결과 = "취약"' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
