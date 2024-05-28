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
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: Apache DocumentRoot가 별도의 디렉터리로 적절히 설정되어 있습니다.
[취약]: Apache DocumentRoot를 기본 디렉터리로 설정했습니다.
[취약]: Apache DocumentRoot가 설정되지 않았습니다.
EOF

webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
document_root_set=false
vulnerable=false

for conf_file in "${webconf_files[@]}"; do
    find_output=$(find / -name "$conf_file" -type f 2>/dev/null)
    for file_path in $find_output; do
        if [[ -n "$file_path" ]]; then
            while IFS= read -r line; do
                if [[ "$line" == DocumentRoot* ]] && [[ ! "$line" =~ ^# ]]; then
                    document_root_set=true
                    path=$(echo $line | awk '{print $2}' | tr -d '"')
                    if [[ "$path" == "/usr/local/apache/htdocs" ]] || [[ "$path" == "/usr/local/apache2/htdocs" ]] || [[ "$path" == "/var/www/html" ]]; then
                        vulnerable=true
                        diagnosisResult="Apache DocumentRoot를 기본 디렉터리로 설정했습니다."
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                        cat $TMP1
                        echo ; echo
                        exit 0
                    fi
                fi
            done < "$file_path"
        fi
    done
done

if [ "$document_root_set" = false ]; then
    diagnosisResult="Apache DocumentRoot가 설정되지 않았습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ "$vulnerable" = false ]; then
    diagnosisResult="Apache DocumentRoot가 별도의 디렉터리로 적절히 설정되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
