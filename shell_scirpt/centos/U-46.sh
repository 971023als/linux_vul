#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-46"
riskLevel="상"
diagnosisItem="일반사용자 메일 실행 제한"
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
# 메일서비스 사용 여부
#########################################
if ss -lntup 2>/dev/null | grep ":25 " >/dev/null; then
    mail_used=true
fi

if ps -ef | grep -E "sendmail|postfix|exim" | grep -v grep >/dev/null; then
    mail_used=true
fi

#########################################
# 미사용
#########################################
if ! $mail_used; then
    diagnosisResult="양호"
    status="메일 서비스 미사용"

else

#########################################
# sendmail restrictqrun
#########################################
if [ -f /etc/mail/sendmail.cf ]; then
    if ! grep -i "restrictqrun" /etc/mail/sendmail.cf >/dev/null; then
        vuln=true
        현황+=("sendmail restrictqrun 미설정")
    else
        현황+=("sendmail restrictqrun 설정")
    fi
fi

#########################################
# postfix postsuper 권한
#########################################
if [ -f /usr/sbin/postsuper ]; then
    perm=$(stat -c "%a" /usr/sbin/postsuper)
    if (( perm % 10 >= 1 )); then
        vuln=true
        현황+=("postsuper others 실행권한 존재")
    fi
fi

#########################################
# exim 권한
#########################################
if [ -f /usr/sbin/exim ]; then
    perm=$(stat -c "%a" /usr/sbin/exim)
    if (( perm % 10 >= 1 )); then
        vuln=true
        현황+=("exim others 실행권한 존재")
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
    status="일반사용자 메일 실행 제한 양호"
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
