#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-38"
riskLevel="상"
diagnosisItem="웹서비스 불필요한 파일 제거"
service=""
diagnosisResult=""
status=""

BAR

CODE="U-38"
diagnosisItem="웹서비스 불필요한 파일 제거"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 모든 검사된 서버에서 불필요한 파일이나 디렉터리가 제거된 상태입니다.
[취약]: 불필요한 파일이나 디렉터리를 찾았습니다.
EOF

BAR

declare -A web_servers
web_servers=(
    ["Apache"]="ServerRoot httpd.conf apache2.conf manual cgi-bin/"
    ["Nginx"]="root nginx.conf html/ docs/ manual/"
    ["LiteSpeed"]="ServerRoot httpd_config.conf _private _vti_bin/ manual/"
    ["Microsoft-IIS"]="aspnet_client/ _vti_bin/ scripts/"
    ["Node.js"]="node_modules/ test/ docs/"
    ["Envoy"]="examples/ docs/"
    ["Caddy"]="root Caddyfile caddy/ examples/"
    ["Tomcat"]="docBase web.xml docs/ examples/ host-manager/ manager/"
)

find_server_roots() {
    local config_files=($1)
    local server_root_directive=$2
    local server_root_directories=()

    if [ -z "$config_files" ]; then
        echo "${server_root_directories[@]}"
        return
    fi

    for conf_file in "${config_files[@]}"; do
        find_command=$(find / -name "$conf_file" -type f 2>/dev/null)
        for file_path in $find_command; do
            if [ -f "$file_path" ]; then
                while IFS= read -r line; do
                    if [[ $line == *"$server_root_directive"* ]] && [[ $line != \#* ]]; then
                        server_root=$(echo $line | awk '{print $2}' | tr -d '";')
                        server_root_directories+=("$server_root")
                    fi
                done < "$file_path"
            fi
        done
    done

    echo "${server_root_directories[@]}"
}

check_unnecessary_files() {
    local server_root_directories=($1)
    local unnecessary_files=($2)
    local found_files=()

    for directory in "${server_root_directories[@]}"; do
        for unnecessary_file in "${unnecessary_files[@]}"; do
            full_path="$directory/$unnecessary_file"
            if [ -e "$full_path" ]; then
                found_files+=("$full_path")
            fi
        done
    done

    echo "${found_files[@]}"
}

overall_found_unnecessary_files=false
vulnerabilities_overall=()

for server_name in "${!web_servers[@]}"; do
    IFS=' ' read -r -a config_and_files <<< "${web_servers[$server_name]}"
    server_root_directive="${config_and_files[0]}"
    config_files=("${config_and_files[@]:1:${#config_and_files[@]}-4}")
    unnecessary_files=("${config_and_files[@]: -3}")

    server_root_directories=($(find_server_roots "${config_files[@]}" "$server_root_directive"))
    found_files=($(check_unnecessary_files "${server_root_directories[@]}" "${unnecessary_files[@]}"))

    if [ "${#found_files[@]}" -gt 0 ]; then
        overall_found_unnecessary_files=true
        for file in "${found_files[@]}"; do
            vulnerabilities_overall+=("$server_name: $file 에서 불필요한 파일이나 디렉터리를 찾았습니다.")
        done
    fi
done

if [ "$overall_found_unnecessary_files" == "true" ]; then
    diagnosisResult="취약"
    status="취약"
    for vulnerability in "${vulnerabilities_overall[@]}"; do
        echo "WARN: $vulnerability" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$vulnerability,$status" >> $OUTPUT_CSV
    done
else
    diagnosisResult="양호"
    status="양호"
    diagnosisResult="모든 검사된 서버에서 불필요한 파일이나 디렉터리가 제거된 상태입니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
