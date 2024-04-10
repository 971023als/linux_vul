#!/bin/bash

# Apache 구성 파일 경로 설정
apache_conf_files=("/etc/apache2/apache2.conf" "/etc/apache2/sites-available/*.conf" "/etc/httpd/conf/httpd.conf")

# 심볼릭 링크 사용 제한 설정 함수
restrict_sym_links() {
    local conf_file=$1
    if [ -f "$conf_file" ]; then
        # 'Options FollowSymLinks' 설정이 있는지 확인하고, 있다면 '-FollowSymLinks'로 변경
        if grep -q "Options FollowSymLinks" "$conf_file"; then
            sed -i 's/Options FollowSymLinks/Options -FollowSymLinks/g' "$conf_file"
            echo "$conf_file 파일에서 심볼릭 링크 사용이 제한되었습니다." | jq --raw-input --slurp '.현황 += [.]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
        else
            echo "$conf_file 파일에 이미 심볼릭 링크 사용이 제한되어 있습니다." | jq --raw-input --slurp '.현황 += [.]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
        fi
    else
        echo "$conf_file 파일을 찾을 수 없습니다." | jq --raw-input --slurp '.현황 += [.]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
}

# 모든 지정된 Apache 구성 파일 업데이트
for conf_file in "${apache_conf_files[@]}"; do
    restrict_sym_links "$conf_file"
done

# 결과 출력
cat $results_file
