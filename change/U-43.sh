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
log_files=(
    "/var/log/auth.log"
    "/var/log/syslog"
    "/var/log/kern.log"
    "/var/log/dmesg"
    "/var/log/faillog"
)

# 로그 파일 존재 여부 및 최근 업데이트 시간 확인
for log_file in "${log_files[@]}"; do
    if [ -f "$log_file" ]; then
        last_modified=$(date -r "$log_file" +"%Y-%m-%d %H:%M:%S")
        jq --arg lf "$log_file" --arg lm "$last_modified" '.현황 += [{"파일명": $lf, "최근 수정 시간": $lm, "결과": "존재함"}]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    else
        jq --arg lf "$log_file" '.현황 += [{"파일명": $lf, "결과": "존재하지 않음"}]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
done

# 결과 출력
cat $results_file
