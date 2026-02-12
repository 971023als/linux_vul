#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더 생성
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

category="서비스 관리"
code="U-63"
riskLevel="중"
diagnosisItem="sudo 명령어 접근 관리"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# sudoers 파일 체크
#############################################
sudoers="/etc/sudoers"

if [ ! -f "$sudoers" ]; then
    diagnosisResult="취약"
    status="/etc/sudoers 파일 없음"
else

    owner=$(stat -c %U $sudoers 2>/dev/null)
    perm=$(stat -c %a $sudoers 2>/dev/null)

    #########################################
    # 권한 점검
    #########################################
    if [ "$owner" != "root" ]; then
        diagnosisResult="취약"
        status="sudoers 소유자 root 아님 ($owner)"
    elif [ "$perm" -gt 640 ]; then
        diagnosisResult="취약"
        status="sudoers 권한 과다 ($perm)"
    else
        diagnosisResult="양호"
        status="소유자 root, 권한 $perm"
    fi
fi

#############################################
# sudo 사용자 현황 (감사용)
#############################################
sudo_users=$(grep -Ev '^#|^$' /etc/sudoers 2>/dev/null | grep ALL | awk '{print $1}' | tr '\n' ' ')

if [ -n "$sudo_users" ]; then
    status="$status | sudo 사용자: $sudo_users"
fi

#############################################
# CSV 기록
#############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#############################################
# 출력
#############################################
cat $OUTPUT_CSV
