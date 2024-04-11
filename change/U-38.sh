#!/bin/bash

# 웹 서버와 해당 불필요한 파일 및 디렉터리 목록
declare -A web_servers=(
    ["Apache"]="/var/www/html/manual /var/www/html/cgi-bin/"
    ["Nginx"]="/usr/share/nginx/html/"
    ["LiteSpeed"]="/usr/local/lsws/DEFAULT/html/_private /usr/local/lsws/DEFAULT/html/manual/"
    # IIS, Node.js, Envoy, Caddy, Tomcat 등 추가 웹 서버 경로 정의 가능
)

# 불필요한 파일 및 디렉터리 제거 함수
remove_unnecessary_files() {
    local server_name=$1
    local paths=$2
    echo "Processing $server_name..."
    for path in $paths; do
        if [ -d "$path" ] || [ -f "$path" ]; then
            echo "Removing $path..."
            rm -rf "$path"
        else
            echo "$path does not exist."
        fi
    done
}

# 웹 서버별 불필요한 파일 및 디렉터리 제거 실행
for server in "${!web_servers[@]}"; do
    remove_unnecessary_files "$server" "${web_servers[$server]}"
done

echo "U-38 "기본으로 생성되는 불필요한 파일 및 디렉터리 제거"
