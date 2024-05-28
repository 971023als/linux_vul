#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-41"
riskLevel="상"
diagnosisItem="웹서비스 영역의 분리"
service=""
diagnosisResult=""
status=""

BAR

CODE="U-41"
diagnosisItem="웹서비스 영역의 분리"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: DocumentRoot가 기본 디렉터리로 적절히 설정되어 있습니다.
[취약]: DocumentRoot가 기본 디렉터리로 설정되어 있습니다.
EOF

BAR

declare -A web_servers
web_servers=(
    ["Apache"]="httpd.conf apache2.conf .htaccess DocumentRoot /usr/local/apache/htdocs /usr/local/apache2/htdocs /var/www/html"
    ["Nginx"]="nginx.conf root /usr/share/nginx/html /var/www/html"
    ["LiteSpeed"]="httpd_config.conf docRoot /usr/local/lsws/DEFAULT/html /var/www/html"
    ["Microsoft-IIS"]="applicationHost.config"
    ["Node.js"]=""
    ["Envoy"]="envoy.yaml"
    ["Caddy"]="Caddyfile root /var/www/html"
    ["Tomcat"]="server.xml context.xml docBase /var/lib/tomcat/webapps/ROOT"
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

check_document_root_settings() {
    local found_files=($1)
    local document_root_directive=$2
    local default_paths=($3)
    local document_root_set=false
    local vulnerable=false
    local file_path=""

    for file_path in "${found_files[@]}"; do
        while IFS= read -r line; do
            if [[ $line == *"$document_root_directive"* ]] && [[ $line != \#* ]]; then
                document_root_set=true
                path=$(echo $line | awk '{print $2}' | tr -d '";')
                for default_path in "${default_paths[@]}"; do
                    if [ "$path" == "$default_path" ]; then
                        vulnerable=true
                        echo "$document_root_set $vulnerable $file_path"
                        return
                    fi
                done
            fi
        done < "$file_path"
    done

    echo "$document_root_set $vulnerable $file_path"
}

overall_document_root_set=false
overall_vulnerable=false
vulnerabilities_overall=()

for server_name in "${!web_servers[@]}"; do
    IFS=' ' read -r -a config_and_directives <<< "${web_servers[$server_name]}"
    config_files=("${config_and_directives[@]:0:${#config_and_directives[@]}-3}")
    document_root_directive="${config_and_directives[-3]}"
    default_paths=("${config_and_directives[@]: -2}")

    found_files=($(find_config_files "${config_files[@]}"))
    check_result=($(check_document_root_settings "${found_files[@]}" "$document_root_directive" "${default_paths[@]}"))
    document_root_set=${check_result[0]}
    vulnerable=${check_result[1]}
    file_path=${check_result[2]}

    if [ "$vulnerable" == "true" ]; then
        overall_vulnerable=true
        vulnerabilities_overall+=("$server_name: $file_path 파일에서 DocumentRoot가 기본 디렉터리로 설정되어 있습니다.")
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
    diagnosisResult="DocumentRoot가 기본 디렉터리로 적절히 설정되어 있습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
