#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-35"
riskLevel="상"
diagnosisItem="공유 서비스 익명 접근 제한"
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
# 1. ftp / anonymous 계정 존재 확인
#########################################
if grep -E "ftp|anonymous" /etc/passwd >/dev/null; then
    vuln=true
    현황+=("ftp 또는 anonymous 계정 존재")
fi

#########################################
# 2. vsftpd anonymous 설정
#########################################
if [ -f /etc/vsftpd/vsftpd.conf ]; then
    if grep -Ei "^anonymous_enable=YES" /etc/vsftpd/vsftpd.conf >/dev/null; then
        vuln=true
        현황+=("vsftpd 익명접속 허용")
    fi
fi

#########################################
# 3. proftpd anonymous
#########################################
if [ -f /etc/proftpd.conf ]; then
    if grep -i "<Anonymous" /etc/proftpd.conf >/dev/null; then
        vuln=true
        현황+=("proftpd anonymous 허용")
    fi
fi

#########################################
# 4. samba guest 접근
#########################################
if [ -f /etc/samba/smb.conf ]; then
    if grep -Ei "guest ok\s*=\s*yes" /etc/samba/smb.conf >/dev/null; then
        vuln=true
        현황+=("samba guest 접근 허용")
    fi
fi

#########################################
# 5. NFS everyone 공유
#########################################
if [ -f /etc/exports ]; then
    if grep -E "\(rw" /etc/exports | grep -E "\*" >/dev/null; then
        vuln=true
        현황+=("NFS everyone(*) 공유 존재")
    fi
fi

#########################################
# 6. ftp 포트 열림 (서비스 사용)
#########################################
if ss -lntup 2>/dev/null | grep ":21 " >/dev/null; then
    ftp_use=true
else
    ftp_use=false
fi

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="익명접속 제한 설정 양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
