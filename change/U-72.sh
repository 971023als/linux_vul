#!/bin/bash

filename="/etc/rsyslog.conf"
expected_content=(
    "*.info;mail.none;authpriv.none;cron.none /var/log/messages"
    "authpriv.* /var/log/secure"
    "mail.* /var/log/maillog"
    "cron.* /var/log/cron"
    "*.alert /dev/console"
    "*.emerg *"
)

# Check for the existence of the logging file
if [ ! -e "$filename" ]; then
    result="취약"
    status+=("$filename 파일이 존재하지 않습니다.")
    echo "$filename 파일을 생성합니다."
    touch "$filename"
    for content in "${expected_content[@]}"; do
        echo "$content" >> "$filename"
    done
    result="조치 완료"
    status=("필요한 로깅 정책이 $filename 파일에 추가되었습니다.")
else
    # Ensure the contents of the logging file match expectations
    modified=false
    for content in "${expected_content[@]}"; do
        if ! grep -Fxq "$content" "$filename"; then
            echo "$content" >> "$filename"
            modified=true
        fi
    done

    if $modified; then
        result="조치 완료"
        status=("누락된 로깅 정책이 $filename 파일에 추가되었습니다.")
    else
        result="양호"
        status=("모든 필수 로깅 정책이 $filename 파일에 이미 설정되어 있습니다.")
    fi
fi

# Print the results
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황:"
for i in "${status[@]}"; do
    echo "- $i"
done
echo "대응방안: $recommendation"
