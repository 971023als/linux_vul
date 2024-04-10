#!/bin/bash

# Apache 구성 파일 경로 설정
apache_conf_files=("/etc/httpd/conf/httpd.conf" "/etc/apache2/apache2.conf")

# Apache가 Non-root 사용자로 실행되도록 설정
update_apache_user_group() {
    local conf_file=$1
    if [ -f "$conf_file" ]; then
        # User 지시어를 non-root 사용자 'www-data'로 설정
        if grep -q "^User" "$conf_file"; then
            sed -i 's/^User.*/User www-data/' "$conf_file"
        else
            echo "User www-data" >> "$conf_file"
        fi

        # Group 지시어를 'www-data' 그룹으로 설정
        if grep -q "^Group" "$conf_file"; then
            sed -i 's/^Group.*/Group www-data/' "$conf_file"
        else
            echo "Group www-data" >> "$conf_file"
        fi

        echo "Apache 구성 파일($conf_file)이 업데이트되었습니다: User와 Group을 www-data로 설정."
    else
        echo "Apache 구성 파일($conf_file)을 찾을 수 없습니다."
    fi
}

# 모든 지정된 Apache 구성 파일 업데이트
for conf_file in "${apache_conf_files[@]}"; do
    update_apache_user_group "$conf_file"
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

echo "웹서비스 웹 프로세스 권한 제한 조치가 완료되었습니다."
