#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "서비스 관리",
    "코드": "U-38",
    "위험도": "상",
    "진단 항목": "웹서비스 불필요한 파일 제거",
    "진단 결과": null,
    "현황": [],
    "대응방안": "기본으로 생성되는 불필요한 파일 및 디렉터리 제거"
}' > $results_file

webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
serverroot_directories=()

for conf_file in "${webconf_files[@]}"; do
    find_output=$(find / -name $conf_file -type f 2>/dev/null)
    for file_path in $find_output; do
        if [[ -n "$file_path" ]]; then
            while IFS= read -r line; do
                if [[ "$line" == ServerRoot* ]] && [[ ! "$line" =~ ^# ]]; then
                    serverroot=$(echo $line | awk '{print $2}' | tr -d '"')
                    if [[ ! " ${serverroot_directories[@]} " =~ " ${serverroot} " ]]; then
                        serverroot_directories+=("$serverroot")
                    fi
                fi
            done < "$file_path"
        fi
    done
done

vulnerable=false
for directory in "${serverroot_directories[@]}"; do
    manual_path="$directory/manual"
    if [[ -d "$manual_path" ]]; then
        vulnerable=true
        jq --arg path "$manual_path" '.현황 += ["Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있지 않습니다: " + $path]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
done

if [ "$vulnerable" = false ]; then
    jq '.진단 결과 = "양호" | .현황 += ["Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    jq '.진단 결과 = "취약"' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
