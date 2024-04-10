#!/bin/bash

# 웹 구성 파일 목록
webconf_files=("/etc/apache2/apache2.conf" "/etc/apache2/conf-enabled/userdir.conf" "/etc/httpd/conf/httpd.conf" "/var/www/html/.htaccess")

# 디렉터리 리스팅 비활성화 설정
disable_directory_listing() {
    for conf_file in "${webconf_files[@]}"; do
        if [ -f "$conf_file" ]; then
            # 'Options Indexes' 설정이 있는지 확인하고, 있다면 '-Indexes'로 변경
            if grep -q "Options Indexes" "$conf_file"; then
                sed -i 's/Options Indexes/Options -Indexes/g' "$conf_file"
                echo "$conf_file 파일에서 디렉터리 리스팅이 비활성화되었습니다."
            fi
            # 'Userdir enabled' 설정이 있는 경우 'Userdir disabled'로 변경
            if grep -q "Userdir enabled" "$conf_file"; then
                sed -i 's/Userdir enabled/Userdir disabled/g' "$conf_file"
                echo "$conf_file 파일에서 Userdir이 비활성화되었습니다."
            fi
        fi
    done
}

# 디렉터리 리스팅 비활성화 실행
disable_directory_listing

# 웹 서버 재시작 (Apache 예시, 다른 웹 서버 사용 시 적절히 변경 필요)
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "Apache 웹 서버가 재시작되었습니다."
elif systemctl is-active --quiet httpd; then
    systemctl restart httpd
    echo "HTTPD 웹 서버가 재시작되었습니다."
else
    echo "웹 서버가 실행 중이지 않거나, 지원되지 않는 웹 서버입니다."
fi

echo "웹서비스 디렉토리 리스팅 제거 조치가 완료되었습니다."
