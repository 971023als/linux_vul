#!/bin/bash

# Apache 구성 파일 경로 설정
apache_conf_files=(
    "/etc/apache2/apache2.conf"
    "/etc/apache2/conf-enabled/*.conf"
    "/etc/httpd/conf/httpd.conf"
)

# 상위 디렉터리 접근 금지 설정 함수
restrict_directory_access() {
    local conf_file=$1
    if [ -f "$conf_file" ]; then
        # AllowOverride 설정 확인 및 업데이트
        if grep -q "AllowOverride None" "$conf_file"; then
            echo "$conf_file 파일에 이미 상위 디렉터리 접근 제한 설정이 적용되어 있습니다."
        else
            echo "<Directory />" >> "$conf_file"
            echo "    AllowOverride None" >> "$conf_file"
            echo "    Require all denied" >> "$conf_file"
            echo "</Directory>" >> "$conf_file"
            echo "$conf_file 파일에 상위 디렉터리 접근 제한 설정을 추가했습니다."
        fi
    else
        echo "$conf_file 파일을 찾을 수 없습니다."
    fi
}

# 모든 지정된 Apache 구성 파일 업데이트
for conf_file in "${apache_conf_files[@]}"; do
    restrict_directory_access "$conf_file"
done

# Apache 서비스 재시작
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "Apache2 서비스가 재시작되었습니다."
elif systemctl is-active --quiet httpd; then
    systemctl restart httpd
    echo "HTTPD 서비스가 재시작되었습니다."
else
    echo "Apache 서비스가 실행 중이지 않거나 인식되지 않습니다."
fi

echo "웹서비스 상위 디렉터리 접근 금지 설정이 완료되었습니다."
