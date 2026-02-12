#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-48"
riskLevel="중"
diagnosisItem="SMTP expn/vrfy 제한"
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

    if grep -i "goaway" /etc/mail/sendmail.cf >/dev/null; then
        현황+=("sendmail goaway 설정")
    else
        if ! grep -i "noexpn" /etc/mail/sendmail.cf >/dev/null; then
            vuln=true
            현황+=("sendmail noexpn 미설정")
        fi

        if ! grep -i "novrfy" /etc/mail/sendmail.cf >/dev/null; then
            vuln=true
            현황+=("sendmail novrfy 미설정")
        fi
    fi
fi

#########################################
# postfix 점검
#########################################
if command -v postconf >/dev/null 2>&1; then
    vrfy=$(postconf -n 2>/dev/null | grep disable_vrfy_command)

    if echo "$vrfy" | grep -i "yes" >/dev/null; then
        현황+=("postfix vrfy 제한")
    else
        vuln=true
        현황+=("postfix disable_vrfy_command 미설정")
    fi
fi

#########################################
# exim 점검
#########################################
if [ -f /etc/exim.conf ]; then
    if grep -i "vrfy" /etc/exim.conf | grep -i deny >/dev/null; then
        현황+=("exim vrfy 제한")
    else
        vuln=true
        현황+=("exim vrfy 제한 설정 없음")
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
    status="expn/vrfy 명령 제한 양호"
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
