#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-40"
riskLevel="상"
diagnosisItem="웹서비스 파일 업로드 및 다운로드 제한"
service=""
diagnosisResult=""
status=""

BAR

CODE="U-40"
diagnosisItem="웹서비스 파일 업로드 및 다운로드 제한"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 모든 검사된 웹서비스 설정 파일에서 파일 업로드 및 다운로드가 적절히 제한되어 있습니다.
[취약]: 파일 업로드 및 다운로드 제한 설정이 부적절합니다.
EOF

BAR

declare -A web_servers
web_servers=(
    ["Apache"]="httpd.conf apache2.conf .htaccess LimitRequestBody"
    ["Nginx"]="nginx.conf client_max_body_size"
    ["LiteSpeed"]="httpd_config.conf .htaccess MaxRequestBodySize"
    ["Microsoft-IIS"]="web.config maxAllowedContentLength"
    ["Node.js"]="body-parser limit"
    ["Envoy"]="envoy.yaml max_request_bytes"
    ["Caddy"]="Caddyfile max_request_body"
    ["Tomcat"]="server.xml web.xml maxPostSize"
)

find_config_files() {
    local config_files=($1)
    local found_files=()

    for conf_file in "${config_files[@]}"; do
        find_command=$(find / -name "$conf_file" -type f 2>/dev/null)
        for file_path in $find_command; do
            if [ -f "$file_path" ]; then
                found_files+=("$file_path")
            fi
        done
    done

    echo "${found_files[@]}"
}

check_upload_download_restrictions() {
    local found_files=($1)
    local upload_directive=$2
    local download_directive=$3
    local vulnerabilities=()

    for file_path in "${found_files[@]}"; do
        while IFS= read -r line; do
            if [[ $line == *"$upload_directive"* ]] && [[ $line != *"$download_directive"* ]]; then
                vulnerabilities+=("$file_path")
                break
            fi
        done < "$file_path"
    done

    echo "${vulnerabilities[@]}"
}

overall_vulnerable=false
vulnerabilities_overall=()

for server_name in "${!web_servers[@]}"; do
    IFS=' ' read -r -a config_and_directives <<< "${web_servers[$server_name]}"
    config_files=("${config_and_directives[@]:0:${#config_and_directives[@]}-2}")
    upload_directive="${config_and_directives[-2]}"
    download_directive="${config_and_directives[-1]}"

    found_files=($(find_config_files "${config_files[@]}"))
    vulnerabilities=($(check_upload_download_restrictions "${found_files[@]}" "$upload_directive" "$download_directive"))

    if [ "${#vulnerabilities[@]}" -gt 0 ]; then
        overall_vulnerable=true
        for vulnerability in "${vulnerabilities[@]}"; do
            vulnerabilities_overall+=("$server_name: $vulnerability 파일에서 파일 업로드 및 다운로드 제한 설정이 부적절합니다.")
        done
    fi
done

if [ "$overall_vulnerable" == "true" ]; then
    diagnosisResult="취약"
    status="취약"
    for vulnerability in "${vulnerabilities_overall[@]}"; do
        echo "WARN: $vulnerability" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$vulnerability,$status" >> $OUTPUT_CSV
    done
else
    diagnosisResult="양호"
    status="양호"
    diagnosisResult="모든 검사된 웹서비스 설정 파일에서 파일 업로드 및 다운로드가 적절히 제한되어 있습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
