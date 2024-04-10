#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "패치 관리",
    "코드": "U-42",
    "위험도": "상",
    "진단 항목": "최신 보안패치 및 벤더 권고사항 적용",
    "진단 결과": null,
    "현황": [],
    "대응방안": "패치 적용 정책 수립 및 주기적인 패치 관리"
}' > $results_file

# Ubuntu 시스템에서 보안 패치를 확인하는 명령어 실행
output=$(sudo unattended-upgrades --dry-run --debug 2>&1)

# 출력 내용에서 보안 패치 여부를 확인
if [[ $output == *"All upgrades installed"* ]]; then
    jq '.진단 결과 = "양호" | .현황 = "시스템은 최신 보안 패치를 보유하고 있습니다."' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    jq '.진단 결과 = "취약" | .현황 = "시스템에 보안 패치가 필요합니다."' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
