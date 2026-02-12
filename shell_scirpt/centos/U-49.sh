#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-49"
riskLevel="상"
diagnosisItem="DNS(BIND) 보안패치 점검"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
dns_used=false
vuln=false
현황=()

#########################################
# DNS 서비스 실행 여부 확인
#########################################

# named 프로세스
if ps -ef | grep named | grep -v grep >/dev/null; then
    dns_used=true
fi

# 53포트 사용 여부
if ss -lntup 2>/dev/null | grep ":53 " >/dev/null; then
    dns_used=true
fi

#########################################
# DNS 미사용 → 양호
#########################################
if ! $dns_used; then
    diagnosisResult="양호"
    status="DNS 서비스 미사용"

else

#########################################
# BIND 버전 확인
#########################################
if command -v named >/dev/null 2>&1; then

    version=$(named -v 2>/dev/null)

    if [ -n "$version" ]; then
        현황+=("BIND 사용: $version")

        # 매우 구버전 탐지 (9.8 이하 등)
        major=$(echo $version | cut -d. -f1 | tr -dc '0-9')
        minor=$(echo $version | cut -d. -f2 | tr -dc '0-9')

        if [ "$major" -lt 9 ]; then
            vuln=true
            현황+=("구버전 BIND 가능")
        fi

    else
        vuln=true
        현황+=("BIND 버전 확인 불가")
    fi

else
    vuln=true
    현황+=("named 명령 없음 (비정상 DNS)")
fi

#########################################
# 패키지 확인 (Linux)
#########################################
if command -v rpm >/dev/null 2>&1; then
    pkg=$(rpm -qa | grep -i bind | head -1)
    if [ -n "$pkg" ]; then
        현황+=("패키지: $pkg")
    fi
fi

if command -v dpkg >/dev/null 2>&1; then
    pkg=$(dpkg -l | grep bind9 | head -1)
    if [ -n "$pkg" ]; then
        현황+=("패키지: bind9 설치")
    fi
fi

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status=$(IFS=' | '; echo "${현황[*]}")
fi

fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
