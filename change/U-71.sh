#!/bin/bash

# Apache 서버 정보 숨김 설정
ApacheConfigPaths=("/etc/apache2/apache2.conf" "/etc/httpd/conf/httpd.conf")
for configPath in "${ApacheConfigPaths[@]}"; do
  if [ -f "$configPath" ]; then
    sudo sed -i '/ServerTokens/d' "$configPath"
    echo "ServerTokens Prod" | sudo tee -a "$configPath"
    sudo sed -i '/ServerSignature/d' "$configPath"
    echo "ServerSignature Off" | sudo tee -a "$configPath"
    # Apache 재시작 (실제 환경에 맞게 조정 필요)
    sudo systemctl restart apache2 || sudo systemctl restart httpd
  fi
done

# Nginx 서버 정보 숨김 설정
if [ -f "/etc/nginx/nginx.conf" ]; then
  sudo sed -i '/server_tokens/d' "/etc/nginx/nginx.conf"
  echo "server_tokens off;" | sudo tee -a "/etc/nginx/nginx.conf"
  # Nginx 재시작 (실제 환경에 맞게 조정 필요)
  sudo systemctl restart nginx
fi

# Caddy 서버 정보 숨김 설정 (Caddyfile 경로가 정확해야 함)
CaddyFilePath="/etc/caddy/Caddyfile"
if [ -f "$CaddyFilePath" ]; then
  echo "header / -Server" | sudo tee -a "$CaddyFilePath"
  # Caddy 재시작 (실제 환경에 맞게 조정 필요)
  sudo systemctl reload caddy
fi

echo "U-71 웹 서버 정보 숨김 설정 조치가 완료되었습니다."
