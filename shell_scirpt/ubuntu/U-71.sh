#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-71"
riskLevel="중"
diagnosisItem="웹 서비스 정보 숨김"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 웹 서버 정보 숨김 설정이 적절히 구성되어 있습니다.
[취약]: 웹 서버 정보 숨김 설정이 적절히 구성되어 있지 않습니다.
EOF

declare -A web_servers=(
    [Apache]="httpd.conf apache2.conf .htaccess ServerTokens:Prod ServerSignature:Off"
    [Nginx]="nginx.conf server_tokens:off"
    [LiteSpeed]="httpd_config.conf ServerTokens:Prod ServerSignature:Off"
    [Microsoft-IIS]=" Use URL Rewrite to remove Server header:Server header removed"
    [Node.js]=" Set custom Server header in response:Custom Server header value"
    [Envoy]="envoy.yaml server_name:Custom Server Name"
    [Caddy]="Caddyfile header:-Server"
    [Tomcat]="server.xml web.xml server:Custom Server Name Header:Remove Server header"
)

overall_status="취약"

check_configuration() {
    local config_files directives
    IFS=' ' read -r -a config_files <<< "$1"
    IFS=' ' read -r -a directives <<< "$2"
    
    for config_file in "${config_files[@]}"; do
        find_result=$(find / -name "$config_file" -type f 2>/dev/null)
        for file in $find_result; do
            if [[ -f $file ]]; then
                file_content=$(cat "$file")
                all_directives_correct=true
                for directive in "${directives[@]}"; do
                    key=$(echo "$directive" | cut -d':' -f1)
                    value=$(echo "$directive" | cut -d':' -f2)
                    if ! echo "$file_content" | grep -q -i "$key.*$value"; then
                        all_directives_correct=false
                        break
                    fi
                done
                if $all_directives_correct; then
                    return 0
                fi
            fi
        done
    done
    return 1
}

for server in "${!web_servers[@]}"; do
    config_directives="${web_servers[$server]}"
    config_files="${config_directives%% *}"
    directives="${config_directives#* }"
    
    if check_configuration "$config_files" "$directives"; then
        status="양호"
        diagnosisResult="$server 설정이 적절히 설정되어 있습니다."
        overall_status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="$server 웹 서버에서 정보 숨김 설정이 적절히 구성되어 있지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        overall_status="취약"
    fi
done

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$overall_status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
