#!/bin/bash

# Apache와 Nginx에 대한 디렉터리 리스팅 방지 설정 스크립트 예시

# Apache 설정 변경
apache_config="/etc/httpd/conf/httpd.conf"  # Apache 설정 파일 위치
if [ -f "$apache_config" ]; then
    if grep -q "Options Indexes" "$apache_config"; then
        echo "Apache에서 디렉터리 리스팅을 비활성화합니다."
        sed -i 's/Options Indexes/Options -Indexes/' "$apache_config"
        systemctl restart httpd
        echo "U-35 Apache 설정을 업데이트하고 서비스를 재시작했습니다."
    else
        echo "U-35 Apache에서 이미 디렉터리 리스팅이 비활성화되어 있습니다."
    fi
else
    echo "U-35 Apache 설정 파일이 존재하지 않습니다."
fi

# Nginx 설정 변경
nginx_config="/etc/nginx/nginx.conf"  # Nginx 설정 파일 위치
if [ -f "$nginx_config" ]; then
    if grep -q "autoindex on;" "$nginx_config"; then
        echo "Nginx에서 디렉터리 리스팅을 비활성화합니다."
        sed -i 's/autoindex on;/autoindex off;/' "$nginx_config"
        systemctl restart nginx
        echo "U-35 Nginx 설정을 업데이트하고 서비스를 재시작했습니다."
    else
        echo "U-35 Nginx에서 이미 디렉터리 리스팅이 비활성화되어 있습니다."
    fi
else
    echo "U-35 Nginx 설정 파일이 존재하지 않습니다."
fi

# 이 스크립트는 Apache와 Nginx 웹 서버에 대한 디렉터리 리스팅 방지 설정 예시를 제공합니다.
# LiteSpeed, Microsoft-IIS, Node.js, Envoy, Caddy, Tomcat 등 다른 웹 서버의 경우에는
# 해당 서버의 설정 파일 위치와 방지 방법을 확인한 후, 위의 예시를 참고하여 적절한 조치를 취해야 합니다.
