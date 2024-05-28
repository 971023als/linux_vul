#!/bin/bash

# CSV Output File
OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-35"
riskLevel="상"
diagnosisItem="웹서비스 디렉터리 리스팅 제거"
service=""
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

# Web servers configuration files to check
declare -A web_servers
web_servers=(
    ["Apache"]=".htaccess httpd.conf apache2.conf"
    ["Nginx"]="nginx.conf"
    ["LiteSpeed"]="httpd_config.conf"
    ["Microsoft-IIS"]="applicationHost.config"
    ["Node.js"]="package.json .env"
    ["Envoy"]="envoy.yaml"
    ["Caddy"]="Caddyfile"
    ["Tomcat"]="server.xml web.xml"
)

check_directory_listing_vulnerability() {
    local conf_files=($1)
    local vulnerable=false
    local vulnerabilities=()

    for conf_file in "${conf_files[@]}"; do
        find_command=$(find / -name "$conf_file" -type f 2>/dev/null)
        for file_path in $find_command; do
            if [ -f "$file_path" ]; then
                content=$(grep -i "Options Indexes" "$file_path")
                if [[ $content == *"Options Indexes"* && $content != *"-Indexes"* ]]; then
                    vulnerabilities+=("$file_path")
                    vulnerable=true
                fi
            fi
        done
    done

    echo "$vulnerable" "${vulnerabilities[@]}"
}

# Main script logic
vulnerable_overall=false
vulnerabilities_overall=()

for server_name in "${!web_servers[@]}"; do
    conf_files="${web_servers[$server_name]}"
    result=$(check_directory_listing_vulnerability "$conf_files")
    vulnerable=$(echo $result | cut -d' ' -f1)
    vulnerabilities=$(echo $result | cut -d' ' -f2-)

    if [ "$vulnerable" == "true" ]; then
        vulnerable_overall=true
        for vulnerability in $vulnerabilities; do
            vulnerabilities_overall+=("$vulnerability 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다.")
        done
    fi
done

if [ "$vulnerable_overall" == "true" ]; then
    diagnosisResult="취약"
    status="취약"
    for vulnerability in "${vulnerabilities_overall[@]}"; do
        echo "WARN: $vulnerability" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$vulnerability,$status" >> $OUTPUT_CSV
    done
else
    diagnosisResult="양호"
    status="양호"
    diagnosisResult="웹서비스 디렉터리 리스팅이 적절히 제거되었습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
