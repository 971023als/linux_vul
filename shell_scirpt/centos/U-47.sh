#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-47"
riskLevel="상"
diagnosisItem="스팸 메일 릴레이 제한"
diagnosisResult=""
status=""

# 초기 1줄
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
mail_used=false
vuln=false
현황=()

#########################################
# 메일 서비스 사용 여부
#########################################
if ss -lntup 2>/dev/null | grep ":25 " >/dev/null; then
    mail_used=true
fi

if ps -ef | grep -E "sendmail|postfix|exim" | grep -v grep >/dev/null; then
    mail_used=true
fi

#########################################
# 메일 미사용
#########################################
if ! $mail_used; then
    diagnosisResult="양호"
    status="메일 서비스 미사용"

else

#########################################
# sendmail 점검
#########################################
if [ -f /etc/mail/sendmail.cf ]; then

    if grep -i "promiscuous_relay" /etc/mail/sendmail.cf >/dev/null; then
        vuln=true
        현황+=("sendmail open relay 허용")
    fi

    if [ -f /etc/mail/access ]; then
        현황+=("sendmail access 파일 존재")
    else
        vuln=true
        현황+=("sendmail access 제한 없음")
    fi
fi

#########################################
# postfix 점검
#########################################
if command -v postconf >/dev/null 2>&1; then
    relay=$(postconf -n 2>/dev/null | grep "^mynetworks")

    if echo "$relay" | grep "0.0.0.0" >/dev/null; then
        vuln=true
        현황+=("postfix 전체 릴레이 허용")
    fi

    if [ -z "$relay" ]; then
        vuln=true
        현황+=("postfix 릴레이 제한 설정 없음")
    else
        현황+=("postfix 릴레이 제한 설정 존재")
    fi
fi

#########################################
# exim 점검
#########################################
if [ -f /etc/exim.conf ]; then
    if grep -i "relay_from_hosts = \*" /etc/exim.conf >/dev/null; then
        vuln=true
        현황+=("exim open relay 허용")
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
    status="SMTP 릴레이 제한 설정 양호"
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
