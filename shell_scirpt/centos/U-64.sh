#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

category="패치 관리"
code="U-64"
riskLevel="상"
diagnosisItem="주기적 보안 패치 적용"

diagnosisResult="양호"
status=""

#############################################
# 1. 커널 버전 확인
#############################################
kernel_ver=$(uname -r)
status="kernel:$kernel_ver"

#############################################
# 2. 패치 관리 도구 확인
#############################################
if command -v yum >/dev/null 2>&1; then
    pkg_tool="yum"
elif command -v dnf >/dev/null 2>&1; then
    pkg_tool="dnf"
elif command -v apt >/dev/null 2>&1; then
    pkg_tool="apt"
else
    pkg_tool="unknown"
fi

status="$status | pkg_tool:$pkg_tool"

#############################################
# 3. 업데이트 가능 패키지 점검
#############################################
update_count=0

if [ "$pkg_tool" == "yum" ] || [ "$pkg_tool" == "dnf" ]; then
    update_count=$(yum check-update 2>/dev/null | grep -v "^$" | wc -l)
elif [ "$pkg_tool" == "apt" ]; then
    update_count=$(apt list --upgradable 2>/dev/null | grep -v Listing | wc -l)
fi

status="$status | update_pkg:$update_count"

#############################################
# 4. 자동 패치 정책 확인
#############################################
auto_patch="없음"

if systemctl is-enabled yum-cron >/dev/null 2>&1; then
    auto_patch="yum-cron"
elif systemctl is-enabled dnf-automatic.timer >/dev/null 2>&1; then
    auto_patch="dnf-auto"
elif systemctl is-enabled unattended-upgrades >/dev/null 2>&1; then
    auto_patch="unattended"
fi

status="$status | auto_patch:$auto_patch"

#############################################
# 5. 판단 기준
#############################################
if [ "$pkg_tool" == "unknown" ]; then
    diagnosisResult="취약"
    status="$status | 패치관리도구 미확인"
elif [ "$update_count" -gt 50 ]; then
    diagnosisResult="취약"
    status="$status | 미적용패치 다수"
elif [ "$auto_patch" == "없음" ]; then
    diagnosisResult="취약"
    status="$status | 자동패치정책 없음"
else
    diagnosisResult="양호"
    status="$status | 패치관리 정상"
fi

#############################################
# CSV 기록
#############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#############################################
# 출력
#############################################
cat $OUTPUT_CSV
