#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-36"
riskLevel="상"
diagnosisItem="웹서비스 웹 프로세스 권한 제한"
service=""
diagnosisResult=""
status=""

BAR

CODE="U-36"
diagnosisItem="웹서비스 웹 프로세스 권한 제한"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹서버 프로세스의 권한을 적절히 제한한 경우
[취약]: 웹서버 프로세스의 권한이 적절히 제한되지 않은 경우
EOF

BAR

declare -A web_servers
web_servers=(
    ["Apache"]="httpd.conf apache2.conf"
    ["Nginx"]="nginx.conf"
    ["LiteSpeed"]="httpd_config.conf"
    ["Microsoft-IIS"]="applicationHost.config"
    ["Node.js"]="package.json .env"
    ["Envoy"]="envoy.yaml"
    ["Caddy"]="Caddyfile"
    ["Tomcat"]="server.xml web.xml"
)

check_permissions() {
    local conf_files=($1)
    local user_directive=$2
    local group_directive=$3
    local vulnerable=false
    local vulnerabilities=()

    for conf_file in "${conf_files[@]}"; do
        find_command=$(find / -name "$conf_file" -type f 2>/dev/null)
        for file_path in $find_command; do
            if [ -f "$file_path" ]; then
                if grep -qE "^\s*${user_directive}\s+root" "$file_path"; then
                    vulnerabilities+=("$file_path - 사용자 root 설정")
                    vulnerable=true
                fi
                if [ -n "$group_directive" ] && grep -qE "^\s*${group_directive}\s+root" "$file_path"; then
                    vulnerabilities+=("$file_path - 그룹 root 설정")
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
    conf_files=(${web_servers[$server_name]})
    case $server_name in
        "Apache"|"LiteSpeed")
            user_directive="User"
            group_directive="Group"
            ;;
        "Nginx")
            user_directive="user"
            ;;
        "Tomcat")
            user_directive="tomcat"  # Not a directive, but Tomcat often runs under a 'tomcat' user for security
            ;;
        *)
            user_directive=""
            group_directive=""
            ;;
    esac

    result=$(check_permissions "$conf_files" "$user_directive" "$group_directive")
    vulnerable=$(echo $result | cut -d' ' -f1)
    vulnerabilities=$(echo $result | cut -d' ' -f2-)

    if [ "$vulnerable" == "true" ]; then
        overall_vulnerable=true
        for vulnerability in $vulnerabilities; do
            vulnerabilities_overall+=("$vulnerability")
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
    diagnosisResult="모든 검사된 서버 데몬들이 적절히 권한 제한이 되어 있습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
