#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-33"
riskLevel="상"
diagnosisItem="DNS 보안 버전 패치"
solution="DNS 서비스 주기적 패치 관리"
diagnosisResult=""
status=""
minimum_version="9.18.7"
_status_list=()

TMP1=$(basename "$0").log
> $TMP1

# 버전 비교 함수
compare_versions() {
    if [[ "$1" == "$2" ]]; then
        return 0 # equal
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 1 # less than
        elif ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 2 # greater than
        fi
    done
    return 0 # equal
}

# BIND 버전 확인
if command -v rpm &> /dev/null; then
    bind_version_output=$(rpm -qa | grep '^bind' | grep -oP 'bind(?:9)?-\K(\d+\.\d+\.\d+)')
elif command -v dpkg &> /dev/null; then
    bind_version_output=$(dpkg -l | grep '^ii' | grep 'bind9' | grep -oP 'bind9\s+\K(\d+\.\d+\.\d+)')
fi

# 버전 비교 및 결과 설정
if [[ $bind_version_output ]]; then
    compare_versions $bind_version_output $minimum_version
    case $? in
        1) # less than
            diagnosisResult="BIND 버전이 최신 버전(${minimum_version}) 이상이 아닙니다: ${bind_version_output}"
            status="취약"
            ;;
        *) # equal or greater than
            diagnosisResult="BIND 버전이 최신 버전(${minimum_version}) 이상입니다: ${bind_version_output}"
            status="양호"
            ;;
    esac
else
    diagnosisResult="BIND가 설치되어 있지 않거나 버전을 확인할 수 없습니다."
    status="오류"
fi

_status_list+=("$diagnosisResult")

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

# Output log and CSV file contents
cat $TMP1

echo ; echo


status="${_status_list[*]}"
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
