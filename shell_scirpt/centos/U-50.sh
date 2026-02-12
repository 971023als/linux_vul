#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더 생성
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-50"
riskLevel="상"
diagnosisItem="DNS ZoneTransfer 설정"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

############################################
# 변수
############################################
dns_used=false
vuln=false
현황=()

############################################
# DNS 사용 여부 확인
############################################
if ps -ef | grep named | grep -v grep >/dev/null; then
    dns_used=true
fi

if ss -lntup 2>/dev/null | grep ":53 " >/dev/null; then
    dns_used=true
fi

############################################
# DNS 미사용 → 양호
############################################
if ! $dns_used; then
    diagnosisResult="양호"
    status="DNS 서비스 미사용"

else

############################################
# named 설정파일 위치 후보
############################################
conf_files=(
    "/etc/named.conf"
    "/etc/bind/named.conf"
    "/etc/bind/named.conf.options"
    "/etc/named.boot"
)

found_conf=false
allow_setting=""

for conf in "${conf_files[@]}"; do
    if [ -f "$conf" ]; then
        found_conf=true

        result=$(grep -i "allow-transfer" "$conf" 2>/dev/null)
        xfr=$(grep -i "xfrnets" "$conf" 2>/dev/null)

        if [ -n "$result" ]; then
            allow_setting="$result"
            현황+=("$conf allow-transfer 설정 발견")
        fi

        if [ -n "$xfr" ]; then
            allow_setting="$xfr"
            현황+=("$conf xfrnets 설정 발견")
        fi
    fi
done

############################################
# 설정 파일 없음
############################################
if ! $found_conf; then
    vuln=true
    현황+=("DNS 설정파일(named.conf 등) 미발견")

else

############################################
# allow-transfer 설정 점검
############################################
if [ -z "$allow_setting" ]; then
    vuln=true
    현황+=("Zone Transfer 제한 설정 없음")

else
    echo "$allow_setting" | grep -Ei "any|0.0.0.0|;" >/dev/null
    if [ $? -eq 0 ]; then
        vuln=true
        현황+=("Zone Transfer 전체 허용 가능성")
    else
        현황+=("허용된 IP로 Zone Transfer 제한 설정됨")
    fi
fi

fi

############################################
# 결과
############################################
if $vuln; then
    diagnosisResult="취약"
else
    diagnosisResult="양호"
fi

status=$(IFS=' | '; echo "${현황[*]}")

fi

############################################
# CSV 기록
############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

############################################
# 출력
############################################
cat $OUTPUT_CSV
