#!/bin/bash

# /etc/services에서 FTP 서비스 포트 확인
ftp_ports=$(grep "^ftp\s" /etc/services | awk '{print $2}' | cut -d'/' -f1)
if [[ ! -z "$ftp_ports" ]]; then
    status+=("FTP 포트가 /etc/services에 설정됨: $ftp_ports")
    ftp_found=true
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

# FTP 서비스 비활성화 조치
if [[ "$ftp_found" = true ]]; then
    result="취약"
    # 실행 중인 FTP 서비스 비활성화
    systemctl stop vsftpd.service 2>/dev/null
    systemctl disable vsftpd.service 2>/dev/null
    systemctl stop proftpd.service 2>/dev/null
    systemctl disable proftpd.service 2>/dev/null
    # 상태 업데이트 및 재확인
    if ! ss -tuln | grep -qE ":(21|${ftp_ports}) "; then
        result="양호"
        status=("모든 FTP 서비스가 비활성화되었습니다.")
    else
        status+=("일부 FTP 서비스가 여전히 실행 중입니다. 수동 조치가 필요할 수 있습니다.")
    fi
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