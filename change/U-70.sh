#!/bin/bash

# SMTP 또는 sendmail 서비스 실행 중인지 확인
ps_output=$(ps -ef | grep -E "smtp|sendmail" | grep -v grep)
if [ -z "$ps_output" ]; then
    echo "SMTP 서비스 미사용."
    exit 0
fi

# sendmail.cf 파일 찾기
sendmail_cf_paths=$(find / -name sendmail.cf -type f 2>/dev/null)

if [ -z "$sendmail_cf_paths" ]; then
    echo "SMTP 서비스 사용 중이나, sendmail.cf 파일을 찾을 수 없습니다."
    exit 1
fi

# noexpn 및 novrfy 옵션 설정
for file_path in $sendmail_cf_paths; do
    privacy_options=$(grep "PrivacyOptions" $file_path)
    if [[ $privacy_options == *"noexpn"* ]] && [[ $privacy_options == *"novrfy"* ]]; then
        echo "U-70 $file_path 에서 이미 noexpn 및 novrfy 옵션이 설정되어 있습니다."
    elif [[ $privacy_options == *"goaway"* ]]; then
        echo "U-70 $file_path 에서 goaway 옵션이 설정되어 있으므로 추가 조치가 필요하지 않습니다."
    else
        # PrivacyOptions 줄이 있는 경우, 옵션 추가
        if grep -q "PrivacyOptions" $file_path; then
            sudo sed -i "/PrivacyOptions/c\O PrivacyOptions=noexpn,novrfy" $file_path
        else
            echo "O PrivacyOptions=noexpn,novrfy" | sudo tee -a $file_path > /dev/null
        fi
        echo "U-70 $file_path 에 noexpn 및 novrfy 옵션을 추가하였습니다."
    fi
done
