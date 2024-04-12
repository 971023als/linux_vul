#!/bin/bash

# 로그온 메시지 설정
echo "Authorized users only. All activity may be monitored and reported." | sudo tee /etc/motd /etc/issue.net

# FTP 서비스 로그온 메시지 설정
if [ -f /etc/vsftpd.conf ]; then
    sudo sed -i '/^ftpd_banner=/d' /etc/vsftpd.conf
    echo "ftpd_banner=Authorized users only." | sudo tee -a /etc/vsftpd.conf
fi

if [ -f /etc/proftpd/proftpd.conf ]; then
    sudo sed -i '/^ServerIdent /d' /etc/proftpd/proftpd.conf
    echo "ServerIdent on \"Authorized users only.\"" | sudo tee -a /etc/proftpd/proftpd.conf
fi

if [ -f /etc/pure-ftpd/conf/WelcomeMsg ]; then
    echo "Authorized users only." | sudo tee /etc/pure-ftpd/conf/WelcomeMsg
fi

# SMTP 서비스 로그온 메시지 설정
if [ -f /etc/sendmail.cf ]; then
    sudo sed -i '/^#GreetingMessage/d' /etc/sendmail.cf
    sudo sed -i '/^GreetingMessage/d' /etc/sendmail.cf
    echo "GreetingMessage=Authorized users only. All activity may be monitored and reported." | sudo tee -a /etc/sendmail.cf
fi

# DNS 버전 숨김 설정
if [ -f /etc/named.conf ]; then
    if ! grep -q 'version "[^"]*";' /etc/named.conf; then
        sudo sed -i '/options {/a \\tversion "not currently available";' /etc/named.conf
    fi
fi

echo "U-68 보안 조치가 완료되었습니다."
