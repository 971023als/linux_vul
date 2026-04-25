#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-39"
riskLevel="상"
diagnosisItem="웹서비스 링크 사용금지"
service=""
diagnosisResult=""
status=""

BAR

CODE="U-39"
diagnosisItem="웹서비스 링크 사용금지"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 모든 검사된 웹서비스 설정 파일에서 심볼릭 링크 사용이 적절히 제한되어 있습니다.
[취약]: 심볼릭 링크 사용 제한 설정이 부적절합니다.
EOF

BAR

declare -A web_servers
web_servers=(
    ["Apache"]="httpd.conf apache2.conf .htaccess Options\ FollowSymLinks Options\ -FollowSymLinks"
    ["Nginx"]="nginx.conf disable_symlinks disable_symlinks\ if_not_owner\ from=\$document_root;"
    ["LiteSpeed"]="httpd_config.conf .htaccess Options\ FollowSymLinks Options\ -FollowSymLinks"
    ["Microsoft-IIS"]="web.config"
    ["Node.js"]=""
    ["Envoy"]="envoy.yaml"
    ["Caddy"]="Caddyfile"
    ["Tomcat"]="server.xml web.xml allowLinking allowLinking=\"false\""
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

check_link_usage_restriction() {
    local found_files=($1)
    local link_restriction_directive=$2
    local correct_restriction_setting=$3
    local vulnerabilities=()

    for file_path in "${found_files[@]}"; do
        while IFS= read -r line; do
            if [[ $line == *"$link_restriction_directive"* ]] && [[ $line != *"$correct_restriction_setting"* ]]; then
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
    IFS=' ' read -r -a config_and_settings <<< "${web_servers[$server_name]}"
    config_files=("${config_and_settings[@]:0:${#config_and_settings[@]}-2}")
    link_restriction_directive="${config_and_settings[-2]}"
    correct_restriction_setting="${config_and_settings[-1]}"

    found_files=($(find_config_files "${config_files[@]}"))
    vulnerabilities=($(check_link_usage_restriction "${found_files[@]}" "$link_restriction_directive" "$correct_restriction_setting"))

    if [ "${#vulnerabilities[@]}" -gt 0 ]; then
        overall_vulnerable=true
        for vulnerability in "${vulnerabilities[@]}"; do
            vulnerabilities_overall+=("$server_name: $vulnerability 파일에서 심볼릭 링크 사용 제한 설정이 부적절합니다.")
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
    diagnosisResult="모든 검사된 웹서비스 설정 파일에서 심볼릭 링크 사용이 적절히 제한되어 있습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo


# ==== MD OUTPUT (stdout — shell_runner.sh 가 캡처하여 stdout.txt 저장) ====
_md_code="${code:-${CODE:-U-??}}"
_md_category="${category:-}"
_md_risk="${riskLevel:-${severity:-}}"
_md_item="${diagnosisItem:-${check_item:-진단항목}}"
_md_result="${diagnosisResult:-${result:-}}"
_md_status="${status:-${details:-${service:-}}}"
_md_solution="${solution:-${recommendation:-}}"

cat << __MD_EOF__
# ${_md_code}: ${_md_item}

| 항목 | 내용 |
|------|------|
| 분류 | ${_md_category} |
| 코드 | ${_md_code} |
| 위험도 | ${_md_risk} |
| 진단항목 | ${_md_item} |
| 진단결과 | ${_md_result} |
| 현황 | ${_md_status} |
| 대응방안 | ${_md_solution} |
__MD_EOF__
