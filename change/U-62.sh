#!/bin/bash

# FTP 계정 쉘 제한 조치 스크립트

# FTP 계정의 쉘을 /bin/false로 설정
restrict_ftp_shell() {
    echo "FTP 계정의 쉘을 제한 중..."

    # /etc/passwd 파일에서 'ftp' 계정 찾기
    if grep -q "^ftp:" /etc/passwd; then
        # 현재 설정된 쉘 확인
        current_shell=$(getent passwd ftp | cut -d: -f7)
        if [ "$current_shell" != "/bin/false" ]; then
            # 쉘을 /bin/false로 변경
            usermod -s /bin/false ftp
            echo "U-62 ftp 계정의 쉘을 /bin/false로 변경했습니다."
        else
            echo "U-62 ftp 계정은 이미 /bin/false로 설정되어 있습니다."
        fi
    else
        echo "U-62 ftp 계정이 시스템에 존재하지 않습니다."
    fi
}

main() {
    restrict_ftp_shell
}

main
