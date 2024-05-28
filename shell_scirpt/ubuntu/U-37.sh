#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-37"
riskLevel="상"
diagnosisItem="웹서비스 상위 디렉토리 접근 금지"
service=""
diagnosisResult=""
status=""

BAR

CODE="U-37"
diagnosisItem="웹서비스 상위 디렉토리 접근 금지"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 상위 디렉터리에 이동 제한 설정이 적절히 설정된 경우
[취약]: 상위 디렉터리에 이동 제한 설정이 부적절한 경우
EOF

BAR

declare -A web_servers
web_servers=(
    ["Apache"]="httpd.conf apache2.conf .htaccess AllowOverride\ None"
    ["Nginx"]="nginx.conf deny\ all;"
    ["LiteSpeed"]="httpd_config.conf .htaccess AllowOverride\ None"
    ["Microsoft-IIS"]="web.config <authorization><deny\ users=\"?\"\ /></authorization>"
    ["Node.js"]=""  # No standard config files to search
    ["Envoy"]="envoy.yaml Apply\ RBAC\ policies\ in\ configuration\ to\ restrict\ access"
    ["Caddy"]="Caddyfile respond\ /forbidden/*\ 403"
    ["Tomcat"]="web.xml <security-constraint><web-resource-collection><url-pattern>/restricted/*</url-pattern></web-resource-collection><auth-constraint/></security-constraint>"
)

check_access_restrictions() {
    local conf_files=($1)
    local restriction_setting=$2
    local vulnerable=false
    local vulnerabilities=()

    for conf_file in "${conf_files[@]}"; do
        find_command=$(find / -name "$conf_file" -type f 2>/dev/null)
        for file_path in $find_command; do
            if [ -f "$file_path" ]; then
                if ! grep -q "$restriction_setting" "$file_path"; then
                    vulnerabilities+=("$file_path")
                    vulnerable=true
                fi
            fi
        done
    done

    echo "$vulnerable" "${vulnerabilities[@]}"
}

overall_vulnerable=false
vulnerabilities_overall=()

for server_name in "${!web_servers[@]}"; do
    IFS=' ' read -r -a config_and_setting <<< "${web_servers[$server_name]}"
    conf_files=("${config_and_setting[@]:0:${#config_and_setting[@]}-1}")
    restriction_setting="${config_and_setting[-1]}"

    if [ -n "$restriction_setting" ]; then
        result=$(check_access_restrictions "$conf_files" "$restriction_setting")
        vulnerable=$(echo $result | cut -d' ' -f1)
        vulnerabilities=$(echo $result | cut -d' ' -f2-)

        if [ "$vulnerable" == "true" ]; then
            overall_vulnerable=true
            for vulnerability in $vulnerabilities; do
                vulnerabilities_overall+=("$vulnerability 파일에서 $server_name 상위 디렉터리 접근 제한 설정이 부적절합니다.")
            done
        fi
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
    diagnosisResult="모든 검사된 파일에서 상위 디렉터리 접근 제한 설정이 적절히 설정되어 있습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
