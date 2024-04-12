#!/bin/bash

# 파일 업로드 제한 설정
upload_limit="10M"  # 예시 값

# Apache 웹 서버 업로드 제한 설정
apache_config_files=("/etc/httpd/conf/httpd.conf" "/etc/apache2/apache2.conf")
for config_file in "${apache_config_files[@]}"; do
    if [ -f "$config_file" ]; then
        echo "Setting upload limit in $config_file..."
        sed -i "/<Directory \/var\/www\/>/,/<\/Directory>/ s/LimitRequestBody.*/LimitRequestBody $upload_limit/" "$config_file"
    fi
done
systemctl restart httpd || systemctl restart apache2

# Nginx 웹 서버 업로드 제한 설정
nginx_config_file="/etc/nginx/nginx.conf"
if [ -f "$nginx_config_file" ]; then
    echo "Setting upload limit in $nginx_config_file..."
    sed -i "/http {/a \    client_max_body_size $upload_limit;" "$nginx_config_file"
    systemctl restart nginx
fi

# 기타 웹 서버 설정이 필요한 경우 여기에 추가합니다.
# 예를 들어, LiteSpeed, Microsoft-IIS, Node.js 등 다른 웹 서버의 경우,
# 각 서버의 설정 방식에 따라 적절한 명령어를 추가해야 합니다.

echo "U-42 Web server file upload limits have been updated."
