#!/bin/bash

# 웹 서버 구성 파일 및 필요한 수정사항 정의
declare -A web_servers=(
    ["Apache"]="/etc/apache2/apache2.conf /etc/httpd/conf/httpd.conf"
    ["Nginx"]="/etc/nginx/nginx.conf"
    # LiteSpeed, Caddy, Tomcat 등 추가 서버 구성 파일 경로
)

# Apache에 대한 심볼릭 링크 사용 금지 설정
restrict_apache() {
    for conf_file in ${web_servers["Apache"]}; do
        if [ -f "$conf_file" ]; then
            echo "Updating $conf_file to restrict symbolic link usage..."
            # 'FollowSymLinks'를 '-FollowSymLinks'로 변경합니다.
            sed -i 's/Options Indexes FollowSymLinks/Options Indexes -FollowSymLinks/' "$conf_file"
            # Apache 서버를 재시작합니다.
            systemctl restart apache2 || systemctl restart httpd
        fi
    done
}

# Nginx에 대한 심볼릭 링크 사용 금지 설정
restrict_nginx() {
    for conf_file in ${web_servers["Nginx"]}; do
        if [ -f "$conf_file" ]; then
            echo "Updating $conf_file to restrict symbolic link usage..."
            # 'disable_symlinks' 지시어를 추가합니다.
            if ! grep -q "disable_symlinks" "$conf_file"; then
                sed -i '/server_name/a \    disable_symlinks from=$document_root;' "$conf_file"
                # Nginx 서버를 재시작합니다.
                systemctl restart nginx
            fi
        fi
    done
}

# 메인 실행 함수
main() {
    echo "Restricting symbolic link usage for web servers..."
    restrict_apache
    restrict_nginx
    # 추가 웹 서버에 대한 함수 호출
    echo "U-39 Symbolic link usage restriction process completed."
}

main
