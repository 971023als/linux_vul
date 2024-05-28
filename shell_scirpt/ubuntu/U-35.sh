#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-35"
riskLevel="상"
diagnosisItem="웹서비스 디렉토리 리스팅 제거"
solution="디렉터리 검색 기능 사용하지 않기"
diagnosisResult=""
status=""
현황=()
vulnerable=0

# 웹 구성 파일 목록
webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")

# 웹 구성 파일 검사
for conf_file in "${webconf_files[@]}"; do
    find_output=$(find / -name $conf_file -type f 2>/dev/null)
    IFS=$'\n' # find 명령어의 출력을 줄 단위로 분리
    for file_path in $find_output; do
        if [ -n "$file_path" ]; then
            if grep -qi "options indexes" "$file_path" && ! grep -qi "-indexes" "$file_path"; then
                if [ "$conf_file" == "userdir.conf" ]; then
                    if ! grep -qi "userdir disabled" "$file_path"; then
                        vulnerable=1
                        현황+=("$file_path 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다.")
                        break 2
                    fi
                else
                    vulnerable=1
                    현황+=("$file_path 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다.")
                    break 2
                fi
            fi
        fi
    done
done

# 진단 결과 설정
if [ $vulnerable -eq 0 ]; then
    diagnosisResult="웹서비스 디렉터리 리스팅이 적절히 제거되었습니다."
    status="양호"
    현황+=("웹서비스 디렉터리 리스팅이 적절히 제거되었습니다.")
else
    diagnosisResult="웹서비스 디렉터리 리스팅이 설정되어 있습니다."
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
