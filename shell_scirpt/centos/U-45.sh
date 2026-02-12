#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-45"
riskLevel="상"
diagnosisItem="메일 서비스 버전 점검"
diagnosisResult=""
status=""

# 초기 1줄
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
mail_used=false
버전정보=()

#########################################
# sendmail 확인
#########################################
if command -v sendmail >/dev/null 2>&1; then
    if ps -ef | grep sendmail | grep -v grep >/dev/null; then
        mail_used=true
        ver=$(sendmail -d0.1 -bv root 2>/dev/null | grep Version | head -1)
        [ -z "$ver" ] && ver=$(sendmail -d0.1 2>/dev/null | grep Version | head -1)
        버전정보+=("sendmail:$ver")
    fi
fi

#########################################
# postfix 확인
#########################################
if command -v postconf >/dev/null 2>&1; then
    if systemctl is-active postfix 2>/dev/null | grep -q active; then
        mail_used=true
        ver=$(postconf mail_version 2>/dev/null)
        버전정보+=("postfix:$ver")
    fi
fi

#########################################
# exim 확인
#########################################
if command -v exim >/dev/null 2>&1; then
    if ps -ef | grep exim | grep -v grep >/dev/null; then
        mail_used=true
        ver=$(exim -bV 2>/dev/null | head -1)
        버전정보+=("exim:$ver")
    fi
fi

#########################################
# 포트 25 확인 (smtp)
#########################################
if ss -lntup 2>/dev/null | grep ":25 " >/dev/null; then
    mail_used=true
fi

#########################################
# 결과
#########################################
if ! $mail_used; then
    diagnosisResult="양호"
    status="메일 서비스 미사용"
else
    if [ ${#버전정보[@]} -eq 0 ]; then
        diagnosisResult="취약"
        status="메일서비스 실행중이나 버전확인 불가"
    else
        diagnosisResult="양호"
        status=$(IFS=' | '; echo "${버전정보[*]}")
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
