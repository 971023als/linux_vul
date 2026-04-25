#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-59"
riskLevel="하"
diagnosisItem="숨겨진 파일 및 디렉터리 검색 및 제거"
service="File and Directory Management"
diagnosisResult=""
status=""

# 시작 경로 설정, 예를 들어 사용자의 홈 디렉터리
start_path="$HOME"

# 숨겨진 파일 및 디렉터리 검색
hidden_files=()
hidden_dirs=()
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        hidden_files+=("$file")
    elif [[ -d "$file" ]]; then
        hidden_dirs+=("$file")
    fi
done < <(find "$start_path" -name ".*" -print0)

# 진단 결과 업데이트
if [ ${#hidden_files[@]} -eq 0 ] && [ ${#hidden_dirs[@]} -eq 0 ]; then
    diagnosisResult="숨겨진 파일이나 디렉터리가 없습니다."
    status="양호"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="숨겨진 파일 및 디렉터리 발견:"
    status="취약"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

    if [ ${#hidden_files[@]} -gt 0 ]; then
        for file in "${hidden_files[@]}"; do
            diagnosisResult="숨겨진 파일: $file"
            status="취약"
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        done
    fi

    if [ ${#hidden_dirs[@]} -gt 0 ]; then
        for dir in "${hidden_dirs[@]}"; do
            diagnosisResult="숨겨진 디렉터리: $dir"
            status="취약"
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        done
    fi
fi

# Output CSV

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
