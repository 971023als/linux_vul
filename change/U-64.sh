#!/bin/bash

# FTP 서비스 root 계정 접근 제한 설정 스크립트

# FTP 서비스 구성 파일 목록
ftpusers_files=(
    "/etc/ftpusers" "/etc/ftpd/ftpusers" "/etc/proftpd.conf"
    "/etc/vsftp/ftpusers" "/etc/vsftp/user_list" "/etc/vsftpd.ftpusers"
    "/etc/vsftpd.user_list"
)

restrict_root_access() {
    echo "FTP 서비스 root 계정 접근 제한 설정 중..."

    # proftpd의 경우
    if grep -q 'RootLogin on' /etc/proftpd.conf; then
        echo "'RootLogin on' 설정을 'RootLogin off'로 변경합니다."
        sed -i 's/RootLogin on/RootLogin off/' /etc/proftpd.conf
    fi

    # vsftpd의 경우
    if [ -f "/etc/vsftpd.conf" ]; then
        if ! grep -q "^userlist_deny=NO" /etc/vsftpd.conf; then
            echo "userlist_deny=NO 설정을 /etc/vsftpd.conf에 추가합니다."
            echo "userlist_deny=NO" >> /etc/vsftpd.conf
        fi
        if ! grep -q "^userlist_enable=YES" /etc/vsftpd.conf; then
            echo "userlist_enable=YES 설정을 /etc/vsftpd.conf에 추가합니다."
            echo "userlist_enable=YES" >> /etc/vsftpd.conf
        fi
        if ! grep -q "^root" /etc/vsftpd.user_list; then
            echo "root 계정을 /etc/vsftpd.user_list에 추가하여 접근을 차단합니다."
            echo "root" >> /etc/vsftpd.user_list
        fi
    fi

    # 일반 ftpusers 파일 처리
    for ftpusers_file in "${ftpusers_files[@]}"; do
        if [ -f "$ftpusers_file" ]; then
            if ! grep -q "^root" "$ftpusers_file"; then
                echo "root 계정을 $ftpusers_file 파일에 추가하여 접근을 차단합니다."
                echo "root" >> "$ftpusers_file"
            fi
        fi
    done

    echo "U-64 FTP 서비스 root 계정 접근 제한 설정 완료."
}

main() {
    restrict_root_access
}

main

# ==== 조치 결과 MD 출력 ====
_change_code="U-64"
_change_item="FTP 서비스 root 계정 접근 제한 설정 중..."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
