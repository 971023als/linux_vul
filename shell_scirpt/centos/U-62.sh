#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-62"
riskLevel="하"
diagnosisItem="로그인 시 경고 메시지 설정"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
warn_set=false
현황=()

#############################################
# 1. 서버 콘솔 배너 (/etc/motd, /etc/issue)
#############################################
for file in /etc/motd /etc/issue; do
    if [ -f "$file" ]; then
        if grep -Ev '^\s*$' "$file" >/dev/null; then
            warn_set=true
            현황+=("$file 배너 설정")
        fi
    fi
done

#############################################
# 2. SSH 배너
#############################################
sshd_config="/etc/ssh/sshd_config"

if [ -f "$sshd_config" ]; then
    banner_file=$(grep -Ei "^Banner" $sshd_config | grep -v '^#' | awk '{print $2}')

    if [ -n "$banner_file" ] && [ -f "$banner_file" ]; then
        if grep -Ev '^\s*$' "$banner_file" >/dev/null; then
            warn_set=true
            현황+=("SSH 배너 설정 ($banner_file)")
        fi
    fi
fi

#############################################
# 3. Telnet 배너
#############################################
if ps -ef | grep telnetd | grep -v grep >/dev/null; then
    if [ -f /etc/issue.net ]; then
        if grep -Ev '^\s*$' /etc/issue.net >/dev/null; then
            warn_set=true
            현황+=("Telnet 배너 설정")
        else
            현황+=("Telnet 배너 미설정")
        fi
    fi
fi

#############################################
# 4. FTP 배너 (vsftpd)
#############################################
vsftp_conf=(
"/etc/vsftpd.conf"
"/etc/vsftpd/vsftpd.conf"
)

for conf in "${vsftp_conf[@]}"; do
    if [ -f "$conf" ]; then
        banner=$(grep -Ei "^ftpd_banner" "$conf" | grep -v '^#')
        if [ -n "$banner" ]; then
            warn_set=true
            현황+=("FTP 배너 설정")
        fi
    fi
done

#############################################
# 결과 판단
#############################################
if $warn_set; then
    diagnosisResult="양호"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="취약"
    status="로그인 경고 배너 미설정"
fi

#############################################
# CSV 기록
#############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#############################################
# 출력
#############################################
cat $OUTPUT_CSV
