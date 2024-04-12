#!/bin/bash

# Apache 서버의 DocumentRoot 변경
update_apache_documentroot() {
    local new_root="/var/www/new_root_directory"  # 새로운 DocumentRoot 경로
    local apache_conf_files=("/etc/httpd/conf/httpd.conf" "/etc/apache2/apache2.conf")
    
    for conf_file in "${apache_conf_files[@]}"; do
        if [ -f "$conf_file" ]; then
            echo "Updating DocumentRoot in $conf_file to $new_root..."
            sed -i "s|DocumentRoot \"/var/www/html\"|DocumentRoot \"$new_root\"|g" "$conf_file"
            sed -i "s|<Directory \"/var/www/html\">|<Directory \"$new_root\">|g" "$conf_file"
            echo "Restarting Apache to apply changes..."
            systemctl restart apache2 || systemctl restart httpd
        fi
    done
}

# Nginx 서버의 root 변경
update_nginx_root() {
    local new_root="/var/www/new_root_directory"  # 새로운 root 경로
    local nginx_conf="/etc/nginx/nginx.conf"
    
    if [ -f "$nginx_conf" ]; then
        echo "Updating root in $nginx_conf to $new_root..."
        sed -i "s|root /usr/share/nginx/html;|root $new_root;|g" "$nginx_conf"
        echo "Restarting Nginx to apply changes..."
        systemctl restart nginx
    fi
}

# 기타 웹 서버에 대한 변경이 필요한 경우 여기에 추가하세요.

main() {
    mkdir -p /var/www/new_root_directory  # 새 DocumentRoot 디렉터리 생성
    update_apache_documentroot
    update_nginx_root
    # 추가 웹 서버에 대한 호출
    echo "U-41 Web server document root updates are complete."
}

main
