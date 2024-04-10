#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "로그 관리",
    "코드": "U-43",
    "위험도": "상",
    "진단 항목": "로그의 정기적 검토 및 보고",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "보안 로그, 응용 프로그램 및 시스템 로그 기록의 정기적 검토, 분석, 리포트 작성 및 보고 조치 실행"
}' > $results_file

# 로그 파일 목록
declare -A log_files=(
    ["UTMP"]="/var/log/utmp"
    ["WTMP"]="/var/log/wtmp"
    ["BTMP"]="/var/log/btmp"
    ["SULOG"]="/var/log/sulog"
    ["XFERLOG"]="/var/log/xferlog"
)

# 로그 파일 존재 여부 확인
for log_name in "${!log_files[@]}"; do
    log_path="${log_files[$log_name]}"
    if [ -f "$log_path" ]; then
        result="존재함"
    else
        result="존재하지 않음"
    fi
    # JSON 형식으로 결과 추가
    jq --arg ln "$log_name" --arg res "$result" '.현황 += [{"파일명": $ln, "결과": $res}]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
done

# 결과 출력
cat $results_file
