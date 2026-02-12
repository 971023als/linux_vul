#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-37"
riskLevel="상"
diagnosisItem="crontab/at 권한 설정 점검"
diagnosisResult=""
status=""

# 초기 1줄
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
vuln=false
현황=()

#########################################
# 권한 체크 함수
#########################################
check_perm() {
    file=$1
    max=$2

    if [ -e "$file" ]; then
        perm=$(stat -c "%a" "$file" 2>/dev/null)
        owner=$(stat -c "%U" "$file" 2>/dev/null)

        if (( perm > max )); then
            vuln=true
            현황+=("$file 권한취약:$perm")
        fi

        if [[ "$owner" != "root" ]]; then
            vuln=true
            현황+=("$file 소유자root아님:$owner")
        fi
    fi
}

#########################################
# 1. crontab 명령
#########################################
check_perm /usr/bin/crontab 750
check_perm /bin/crontab 750

#########################################
# 2. at 명령
#########################################
check_perm /usr/bin/at 750
check_perm /bin/at 750

#########################################
# 3. cron 관련 파일
#########################################
check_perm /etc/crontab 640
check_perm /etc/cron.allow 640
check_perm /etc/cron.deny 640
check_perm /etc/at.allow 640
check_perm /etc/at.deny 640

#########################################
# 4. cron 디렉토리
#########################################
for d in /etc/cron.d /var/spool/cron /var/spool/cron/crontabs; do
    if [ -d "$d" ]; then
        perm=$(stat -c "%a" "$d")
        owner=$(stat -c "%U" "$d")

        if (( perm > 750 )); then
            vuln=true
            현황+=("$d 디렉토리권한취약:$perm")
        fi

        if [[ "$owner" != "root" ]]; then
            vuln=true
            현황+=("$d 소유자root아님")
        fi
    fi
done

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="cron/at 권한 설정 양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
