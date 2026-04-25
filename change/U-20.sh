#!/bin/bash

# Anonymous FTP 사용자 계정 확인
if getent passwd ftp > /dev/null; then
    echo "FTP 사용자 계정이 존재합니다. Anonymous FTP가 활성화되어 있을 수 있습니다."

    # vsftpd 사용 시
    if [ -f /etc/vsftpd.conf ]; then
        # anonymous_enable=YES를 anonymous_enable=NO로 변경
        sed -i 's/anonymous_enable=YES/anonymous_enable=NO/g' /etc/vsftpd.conf
        echo "vsftpd.conf에서 Anonymous FTP를 비활성화했습니다."
    fi

    # proftpd 사용 시
    if [ -f /etc/proftpd/proftpd.conf ]; then
        # Anonymous 섹션 주석 처리
        sed -i '/<Anonymous /,/\/Anonymous>/ s/^/#/' /etc/proftpd/proftpd.conf
        echo "proftpd.conf에서 Anonymous FTP 섹션을 주석 처리했습니다."
    fi

    # FTP 사용자 계정 비활성화 (선택적)
    #usermod -s /sbin/nologin ftp
    #echo "FTP 사용자의 쉘 로그인을 비활성화했습니다."

    # FTP 서비스 재시작
    systemctl restart vsftpd
    systemctl restart proftpd
    echo "FTP 서비스를 재시작했습니다."

else
    echo "U-20 FTP 사용자 계정이 존재하지 않습니다. Anonymous FTP가 비활성화되어 있습니다."
fi

# ==== 조치 결과 MD 출력 ====
_change_code="U-20"
_change_item="FTP 사용자 계정이 존재합니다. Anonymous F"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
