#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-37"
riskLevel="상"
diagnosisItem="웹서비스 상위 디렉토리 접근 금지"
solution="상위 디렉터리에 이동제한 설정"
diagnosisResult=""
status=""
현황=()
found_vulnerability=0

TMP1=$(basename "$0").log
> $TMP1

# 웹 구성 파일 목록
webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")

# 웹 구성 파일 검사
for conf_file in "${webconf_files[@]}"; do
    while IFS= read -r file_path; do
        if [ -f "$file_path" ]; then
            if ! grep -q "AllowOverride None" "$file_path"; then
                found_vulnerability=1
                diagnosisResult="$file_path 파일에 상위 디렉터리 접근 제한 설정이 없습니다."
                status="취약"
                현황+=("$diagnosisResult")
                break
            fi
        fi
    done < <(find / -name $conf_file -type f 2>/dev/null)
    if [ $found_vulnerability -eq 1 ]; then
        break
    fi
done

# 진단 결과 설정
if [ $found_vulnerability -eq 0 ]; then
    diagnosisResult="웹서비스 상위 디렉터리 접근에 대한 제한이 적절히 설정되어 있습니다."
    status="양호"
    현황+=("$diagnosisResult")
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
