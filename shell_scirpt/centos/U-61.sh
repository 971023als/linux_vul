#!/bin/bash

# 변수 초기화
category="서비스 관리"
code="U-61"
severity="하"
check_item="FTP 서비스 확인"
result=""
recommendation="FTP 서비스가 비활성화 되어 있는 경우"
declare -a status

# /etc/services에서 FTP 서비스 포트 확인
ftp_ports=$(grep "^ftp\s" /etc/services | awk '{print $2}' | cut -d'/' -f1)
if [[ ! -z "$ftp_ports" ]]; then
    status+=("FTP 포트가 /etc/services에 설정됨: $ftp_ports")
    ftp_found=true
else
    status+=("/etc/services 파일에서 FTP 포트를 찾을 수 없습니다.")
    ftp_found=false
fi

# 실행 중인 FTP 서비스 확인 (ss 사용)
if ss -tuln | grep -qE ":(21|${ftp_ports}) "; then
    status+=("FTP 서비스가 실행 중입니다.")
    ftp_found=true
fi

# vsftpd 및 proftpd 설정 파일 확인
for ftp_conf in vsftpd.conf proftpd.conf; do
    if find / -name $ftp_conf 2>/dev/null | grep -q $ftp_conf; then
        status+=("$ftp_conf 파일이 시스템에 존재합니다.")
        ftp_found=true
    fi
done

# 일반 FTP 서비스 프로세스 확인
if ps -ef | grep -Eiq 'ftpd|vsftpd|proftpd'; then
    status+=("FTP 관련 프로세스가 실행 중입니다.")
    ftp_found=true
fi

# 진단 결과 업데이트
if [[ "$ftp_found" = true ]]; then
    result="취약"
else
    result="양호"
    status=("FTP 서비스 관련 항목이 시스템에 존재하지 않습니다.")
fi

# 결과 출력
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황:"
for i in "${status[@]}"; do
    echo "- $i"
done
echo "대응방안: $recommendation"
