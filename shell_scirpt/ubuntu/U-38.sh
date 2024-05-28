#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-38"
riskLevel="상"
diagnosisItem="웹서비스 불필요한 파일 제거"
solution="기본으로 생성되는 불필요한 파일 및 디렉터리 제거"
diagnosisResult=""
status=""
현황=()

# 웹 구성 파일 목록
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
serverroot_directories=()

# 웹 구성 파일 검사
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
        현황+=("Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있지 않습니다: $manual_path")
    fi
done

# 진단 결과 설정
if [ "$vulnerable" = false ]; then
    diagnosisResult="Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있습니다."
    status="양호"
    현황+=("$diagnosisResult")
else
    diagnosisResult="Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있지 않습니다."
    status="취약"
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

# Output the diagnosis result and status
echo "분류: $category"
echo "코드: $code"
echo "위험도: $riskLevel"
echo "진단 항목: $diagnosisItem"
echo "진단 결과: $diagnosisResult"
echo "현황:"
for 상태 in "${현황[@]}"; do
    echo "- $상태"
done
echo "대응방안: $solution"

# Output the CSV file contents
cat $OUTPUT_CSV
