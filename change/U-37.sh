#!/bin/bash

# 웹 서버 별 설정 파일 경로와 상위 디렉토리 접근 제한 설정
declare -A web_servers=(
    ["Apache"]="/etc/apache2/apache2.conf /etc/httpd/conf/httpd.conf"
    ["Nginx"]="/etc/nginx/nginx.conf"
    ["LiteSpeed"]="/usr/local/lsws/conf/httpd_config.conf"
    ["Microsoft-IIS"]=""  # IIS 설정은 Windows 환경에서 GUI 또는 PowerShell을 통해 관리됩니다.
    ["Node.js"]=""  # Node.js는 중간웨어를 통해 접근 제한을 구성합니다.
    ["Envoy"]="/etc/envoy/envoy.yaml"
    ["Caddy"]="/etc/caddy/Caddyfile"
    ["Tomcat"]="/etc/tomcat/web.xml"
)

# Apache와 Nginx 예시를 포함한 접근 제한 설정 예시
restrictions=(
    ["Apache"]="AllowOverride None"
    ["Nginx"]="deny all;"
)

# 각 웹 서버 설정 검사 및 업데이트
for server in "${!web_servers[@]}"; do
    echo "Checking $server configurations..."
    IFS=' ' read -ra CONFIG_PATHS <<< "${web_servers[$server]}"
    for config_path in "${CONFIG_PATHS[@]}"; do
        if [ -f "$config_path" ]; then
            echo "Found $config_path"
            if ! grep -q "${restrictions[$server]}" "$config_path"; then
                echo "Updating $config_path to restrict upper directory access..."
                # 설정 업데이트 명령어 예시 (실제 환경에 맞게 수정 필요)
                 echo "${restrictions[$server]}" >> "$config_path"
                # 서비스 재시작 또는 리로드 명령어 예시 (실제 환경에 맞게 수정 필요)
                 systemctl reload apache2 || systemctl reload nginx
            else
                echo "$config_path already restricts upper directory access."
            fi
        else
            echo "$config_path not found."
        fi
    done
done

echo "U-37 상위 디렉터리에 이동 제한 설정"
