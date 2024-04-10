#!/bin/bash

# 파일 업로드 최대 크기 설정 (예: 1048576 bytes = 1MB)
max_upload_size="1048576"

# Apache 구성 파일 경로 설정
apache_conf_files=("/etc/apache2/apache2.conf" "/etc/apache2/sites-available/*.conf" "/etc/httpd/conf/httpd.conf")

# 파일 업로드 및 다운로드 제한 설정 함수
set_file_upload_download_limit() {
    local conf_file=$1
    if [ -f "$conf_file" ]; then
        # LimitRequestBody 설정 확인 및 업데이트
        if ! grep -q "LimitRequestBody" "$conf_file"; then
            echo "<Directory \"/var/www/html\">" >> "$conf_file"
            echo "    LimitRequestBody $max_upload_size" >> "$conf_file"
            echo "</Directory>" >> "$conf_file"
            echo "$conf_file 파일에 파일 업로드 제한 설정을 추가했습니다." | jq --raw-input --slurp '.현황 += [.]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
        else
            echo "$conf_file 파일에 이미 파일 업로드 제한 설정이 적용되어 있습니다." | jq --raw-input --slurp '.현황 += [.]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
        fi
    else
        echo "$conf_file 파일을 찾을 수 없습니다." | jq --raw-input --slurp '.현황 += [.]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
}

# 모든 지정된 Apache 구성 파일 업데이트
for conf_file in "${apache_conf_files[@]}"; do
    set_file_upload_download_limit "$conf_file"
done
# 결과 출력
cat $results_file
