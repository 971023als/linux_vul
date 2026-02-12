#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-53"
riskLevel="하"
diagnosisItem="FTP 서비스 정보 노출 제한"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

########################################
# 변수
########################################
ftp_used=false
banner_exposed=false
현황=()

########################################
# 1. FTP 프로세스 확인
########################################
if ps -ef | egrep "vsftpd|proftpd|pure-ftpd" | grep -v grep >/dev/null; then
    ftp_used=true
    현황+=("FTP 서비스 실행 중")
fi

########################################
# 2. 21번 포트 LISTEN 확인
########################################
if ss -lntup 2>/dev/null | grep ":21 " >/dev/null; then
    ftp_used=true
fi

########################################
# FTP 미사용 → 양호
########################################
if ! $ftp_used; then
    diagnosisResult="양호"
    status="FTP 서비스 미사용"
    echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV
    cat $OUTPUT_CSV
    exit 0
fi

########################################
# 3. vsftpd 설정 점검
########################################
vsftp_files=(
"/etc/vsftpd.conf"
"/etc/vsftpd/vsftpd.conf"
)

for file in "${vsftp_files[@]}"; do
    if [ -f "$file" ]; then
        ftp_used=true

        banner=$(grep -v '^#' "$file" | grep -i ftpd_banner)
        if [ -n "$banner" ]; then
            if echo "$banner" | grep -Ei "vsftpd|ftp|version|linux" >/dev/null; then
                banner_exposed=true
                현황+=("$file 배너에 서비스 정보 노출 가능")
            fi
        else
            banner_exposed=true
            현황+=("$file 배너 설정 없음 (기본 배너 노출 가능)")
        fi
    fi
done

########################################
# 4. ProFTP 점검
########################################
proftpd_conf="/etc/proftpd.conf"
if [ -f "$proftpd_conf" ]; then
    ftp_used=true

    grep -i "ServerIdent" "$proftpd_conf" | grep -i "off" >/dev/null
    if [ $? -ne 0 ]; then
        banner_exposed=true
        현황+=("ProFTP ServerIdent 정보 노출 가능")
    fi
fi

########################################
# 5. pure-ftpd 점검
########################################
if [ -f "/etc/pure-ftpd/pure-ftpd.conf" ]; then
    ftp_used=true

    grep -i "FortunesFile" /etc/pure-ftpd/pure-ftpd.conf >/dev/null
    if [ $? -eq 0 ]; then
        현황+=("pure-ftpd 배너 설정 존재 (확인 필요)")
    fi
fi

########################################
# 결과 판단
########################################
if $banner_exposed; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="FTP 배너 정보 노출 없음"
fi

########################################
# CSV 기록
########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

########################################
# 출력
########################################
cat $OUTPUT_CSV
