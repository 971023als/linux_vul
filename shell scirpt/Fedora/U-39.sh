#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "서비스 관리",
    "코드": "U-39",
    "위험도": "상",
    "진단 항목": "웹서비스 링크 사용금지",
    "진단 결과": null,
    "현황": [],
    "대응방안": "심볼릭 링크, aliases 사용 제한"
}' > $results_file

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
found_vulnerability=false

for conf_file in "${webconf_files[@]}"; do
    find_output=$(find / -name $conf_file -type f 2>/dev/null)
    for file_path in $find_output; do
        if [[ -n "$file_path" ]]; then
            content=$(cat "$file_path")
            if [[ "$content" == *"Options FollowSymLinks"* && "$content" != *"Options -FollowSymLinks"* ]]; then
                found_vulnerability=true
                jq --arg path "$file_path" '.현황 += [$path + " 파일에 심볼릭 링크 사용을 제한하지 않는 설정이 포함되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
                break 2
            fi
        fi
    done
done

if [ "$found_vulnerability" = false ]; then
    jq '.진단 결과 = "양호" | .현황 += ["웹서비스 설정 파일에서 심볼릭 링크 사용이 적절히 제한되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    jq '.진단 결과 = "취약"' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
