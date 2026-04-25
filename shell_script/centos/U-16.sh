#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-16"
위험도="상"
진단항목="/dev에 존재하지 않는 device 파일 점검"
대응방안="/dev에 대한 파일 점검 후 존재하지 않은 device 파일을 제거한 경우"
dev_directory='/dev'
non_device_files=()
진단결과=""
현황=""

TMP1=$(basename "$0").log
> $TMP1

# /dev 디렉터리 검사
for item in "$dev_directory"/*; do
    if [ -f "$item" ]; then
        # 파일이 캐릭터 또는 블록 디바이스가 아닌 경우 목록에 추가
        if [ ! -c "$item" ] && [ ! -b "$item" ]; then
            non_device_files+=("$item")
        fi
    fi
done

# 진단 결과 결정 및 현황 업데이트
if [ ${#non_device_files[@]} -gt 0 ]; then
    진단결과="취약"
    현황=$(printf ", %s" "${non_device_files[@]}")
    현황=${현황:2}
else
    진단결과="양호"
    현황="/dev 디렉터리에 존재하지 않는 device 파일이 없습니다."
fi

# 결과를 로그 파일에 기록
echo "현황: $현황" >> $TMP1

# CSV 파일에 결과 추가
echo "$분류,$코드,$위험도,$진단항목,$대응방안,$진단결과,$현황" >> $OUTPUT_CSV

# 로그 파일 출력
cat $TMP1

# CSV 파일 출력
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
