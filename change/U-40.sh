#!/bin/bash

# 업로드 제한 사이즈 설정 (예: 10M)
upload_limit="10M"

# 웹 서버 구성 파일 경로 및 업로드 제한 설정 필요한 파일
apache_config_files=("/etc/apache2/apache2.conf" "/etc/httpd/conf/httpd.conf")
nginx_config_file="/etc/nginx/nginx.conf"
# LiteSpeed, Microsoft-IIS, Node.js, Envoy, Caddy, Tomcat 등 추가 웹 서버 구성

# Apache에 대한 업로드 제한 설정
restrict_apache_upload() {
    echo "Setting upload size limit for Apache..."
    for conf_file in "${apache_config_files[@]}"; do
        if [ -f "$conf_file" ]; then
            echo "Updating $conf_file..."
            sed -i "/<Directory \/var\/www\/>/,/<\/Directory>/ s/LimitRequestBody [0-9]\+/LimitRequestBody $(echo $upload_limit | sed 's/M/000000/')/" "$conf_file"
        fi
    done
}

# Nginx에 대한 업로드 제한 설정
restrict_nginx_upload() {
    echo "Setting upload size limit for Nginx..."
    if [ -f "$nginx_config_file" ]; then
        echo "Updating $nginx_config_file..."
        sed -i "s/client_max_body_size [0-9]*M;/client_max_body_size $upload_limit;/" "$nginx_config_file"
    fi
}

# 웹 서버 재시작 함수 (서비스명 확인 필요)
restart_web_servers() {
    systemctl restart apache2 || systemctl restart httpd
    systemctl restart nginx
    echo "U-40 Web servers restarted to apply changes."
}

main() {
    restrict_apache_upload
    restrict_nginx_upload
    restart_web_servers
}

main
