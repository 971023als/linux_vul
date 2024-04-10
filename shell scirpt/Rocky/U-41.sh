#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "서비스 관리",
    "코드": "U-41",
    "위험도": "상",
    "진단 항목": "웹서비스 영역의 분리",
    "진단 결과": null,
    "현황": [],
    "대응방안": "DocumentRoot 별도 디렉터리 지정"
}' > $results_file

webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
document_root_set=false
vulnerable=false

for conf_file in "${webconf_files[@]}"; do
    find_output=$(find / -name $conf_file -type f 2>/dev/null)
    for file_path in $find_output; do
        if [[ -n "$file_path" ]]; then
            while IFS= read -r line; do
                if [[ "$line" == DocumentRoot* ]] && [[ ! "$line" =~ ^# ]]; then
                    document_root_set=true
                    path=$(echo $line | awk '{print $2}' | tr -d '"')
                    if [[ "$path" == "/usr/local/apache/htdocs" ]] || [[ "$path" == "/usr/local/apache2/htdocs" ]] || [[ "$path" == "/var/www/html" ]]; then
                        vulnerable=true
                        break 2
                    fi
                fi
            done < "$file_path"
        fi
    done
done

if [ "$document_root_set" = false ]; then
    jq '.진단 결과 = "취약" | .현황 += ["Apache DocumentRoot가 설정되지 않았습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
elif [ "$vulnerable" = true ]; then
    jq '.진단 결과 = "취약" | .현황 += ["Apache DocumentRoot를 기본 디렉터리로 설정했습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    jq '.진단 결과 = "양호" | .현황 += ["Apache DocumentRoot가 별도의 디렉터리로 적절히 설정되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
