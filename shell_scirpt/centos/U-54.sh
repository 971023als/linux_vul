#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-54"
riskLevel="중"
diagnosisItem="암호화되지 않은 FTP 서비스 비활성화"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
plain_ftp_running=false
sftp_running=false
ftps_enabled=false
현황=()

#############################################
# 1. FTP 프로세스 확인
#############################################
if ps -ef | egrep "vsftpd|proftpd|pure-ftpd" | grep -v grep >/dev/null; then
    plain_ftp_running=true
    현황+=("FTP 데몬 실행 중")
fi

#############################################
# 2. 21번 포트 LISTEN 확인 (평문 FTP)
#############################################
if ss -lntup 2>/dev/null | grep ":21 " >/dev/null; then
    plain_ftp_running=true
    현황+=("21번 FTP 포트 활성화")
fi

#############################################
# 3. SFTP 사용 여부 (SSH 기반)
#############################################
if ps -ef | grep sshd | grep -v grep >/dev/null; then
    grep -Ei "^Subsystem.*sftp" /etc/ssh/sshd_config >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        sftp_running=true
        현황+=("SFTP 사용 중")
    fi
fi

#############################################
# 4. FTPS 사용 여부 (vsftpd TLS)
#############################################
vsftp_conf=(
"/etc/vsftpd.conf"
"/etc/vsftpd/vsftpd.conf"
)

for file in "${vsftp_conf[@]}"; do
    if [ -f "$file" ]; then
        grep -i "ssl_enable=YES" "$file" | grep -v '^#' >/dev/null
        if [ $? -eq 0 ]; then
            ftps_enabled=true
            현황+=("FTPS(SSL/TLS) 설정 확인")
        fi
    fi
done

#############################################
# 결과 판단
#############################################
if $plain_ftp_running && ! $ftps_enabled; then
    diagnosisResult="취약"
    status="평문 FTP 서비스 사용 중 (비암호화 전송)"
else
    diagnosisResult="양호"
    if $sftp_running || $ftps_enabled; then
        status="암호화 FTP(SFTP/FTPS) 사용"
    else
        status="FTP 서비스 미사용"
    fi
fi

#############################################
# CSV 기록
#############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#############################################
# 출력
#############################################
cat $OUTPUT_CSV
