#!/bin/bash

# 웹 서버 구성 파일 경로와 예상 사용자를 정의합니다.
declare -A web_servers=(
    ["/etc/httpd/conf/httpd.conf"]="httpd"
    ["/etc/apache2/apache2.conf"]="www-data"
    ["/etc/nginx/nginx.conf"]="nginx"
    # 추가 웹 서버 구성 파일과 사용자를 여기에 정의할 수 있습니다.
)

# 각 구성 파일에 대해 루프를 실행하여 권한 설정을 확인합니다.
for config_path in "${!web_servers[@]}"; do
    expected_user="${web_servers[$config_path]}"
    if [ -f "$config_path" ]; then
        echo "검사 중: $config_path"
        # User 지시어를 찾아 예상 사용자와 비교합니다.
        if grep -E "^User\s+$expected_user" "$config_path" > /dev/null; then
            echo "  $config_path 파일은 적절한 사용자($expected_user)에 의해 실행됩니다."
        else
            echo "  $config_path 파일의 사용자 설정이 적절하지 않습니다. 수정이 필요합니다."
            # 사용자 권한을 수정하는 코드를 여기에 추가할 수 있습니다. 예:
            # sed -i "s/^User\s+.*/User $expected_user/" "$config_path"
        fi
    else
        echo "$config_path 파일을 찾을 수 없습니다."
    fi
done

echo "U-36 웹 서비스 프로세스 권한 검사가 완료되었습니다."
