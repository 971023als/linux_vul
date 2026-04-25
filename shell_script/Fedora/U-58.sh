#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-58"
riskLevel="중"
diagnosisItem="홈디렉토리로 지정한 디렉토리의 존재 관리"
service="File and Directory Management"
diagnosisResult=""
status=""

# 모든 사용자 계정을 확인
while IFS=: read -r username _ uid _ _ home_dir shell; do
  # 시스템 계정 건너뛰기 및 로그인 쉘 없는 계정 건너뛰기
  if [ "$uid" -ge 1000 ] && [[ "$shell" != *"nologin" ]] && [[ "$shell" != *"false" ]]; then
    # 홈 디렉터리가 존재하지 않거나, 관리자가 아닌 계정의 홈 디렉터리가 '/' 인 경우
    if [ ! -d "$home_dir" ] || { [ "$home_dir" == "/" ] && [ "$username" != "root" ]; }; then
      if [ ! -d "$home_dir" ]; then
        diagnosisResult="$username 계정의 홈 디렉터리 ($home_dir) 가 존재하지 않습니다."
        status="취약"
      elif [ "$home_dir" == "/" ]; then
        diagnosisResult="관리자 계정(root)이 아닌데 $username 계정의 홈 디렉터리가 '/'로 설정되어 있습니다."
        status="취약"
      fi
      echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
  fi
done < /etc/passwd

# 진단 결과 설정
if ! grep -q "취약" $OUTPUT_CSV; then
  diagnosisResult="모든 사용자 계정의 홈 디렉터리가 적절히 설정되어 있습니다."
  status="양호"
  echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
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
