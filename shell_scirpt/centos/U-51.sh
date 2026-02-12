#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더 생성
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-51"
riskLevel="중"
diagnosisItem="DNS 서비스 취약한 동적 업데이트 설정"
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
# 설정 파일 후보
############################################
conf_files=(
    "/etc/named.conf"
    "/etc/bind/named.conf"
    "/etc/bind/named.conf.options"
)

found_conf=false
update_setting=""

for conf in "${conf_files[@]}"; do
    if [ -f "$conf" ]; then
        found_conf=true

        result=$(grep -i "allow-update" "$conf" 2>/dev/null)
        if [ -n "$result" ]; then
            update_setting="$result"
            현황+=("$conf allow-update 설정 발견")
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
# allow-update 설정 점검
############################################
if [ -z "$update_setting" ]; then
    # 기본적으로 동적 업데이트 미사용 → 양호
    현황+=("allow-update 설정 없음 (동적 업데이트 비활성)")
else
    echo "$update_setting" | grep -Ei "any" >/dev/null
    if [ $? -eq 0 ]; then
        vuln=true
        현황+=("동적 업데이트 전체 허용(any) 설정됨")
    else
        echo "$update_setting" | grep -Ei "none" >/dev/null
        if [ $? -eq 0 ]; then
            현황+=("동적 업데이트 비활성화 설정(none)")
        else
            현황+=("특정 IP만 동적 업데이트 허용 (접근통제 적용)")
        fi
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
