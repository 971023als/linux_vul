#!/bin/bash

# FTP 사용자 계정 비활성화
if grep -q "^ftp:" /etc/passwd; then
    # FTP 사용자의 로그인 쉘을 /sbin/nologin으로 설정하여 로그인을 차단
    usermod -s /sbin/nologin ftp
    echo "FTP 사용자 계정의 로그인이 차단되었습니다."

    # 필요에 따라 FTP 사용자 계정을 시스템에서 삭제
    # userdel ftp
    # echo "FTP 사용자 계정이 삭제되었습니다."
else
    echo "FTP 사용자 계정이 이미 존재하지 않습니다."
fi

echo "Anonymous FTP 접속 차단 조치가 완료되었습니다."
