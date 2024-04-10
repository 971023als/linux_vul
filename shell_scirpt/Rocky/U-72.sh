#!/bin/bash

# Initialize diagnostic results and current status
category="로그 관리"
code="U-72"
severity="하"
check_item="정책에 따른 시스템 로깅 설정"
result="N/A"  # 수동 확인 필요
declare -a status
recommendation="로그 기록 정책 설정 및 보안 정책에 따른 로그 관리"

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
else
    # Check the contents of the logging file
    content_mismatch=false
    for content in "${expected_content[@]}"; do
        if ! grep -Fxq "$content" "$filename"; then
            content_mismatch=true
            result="취약"
            status+=("$filename 파일의 내용이 잘못되었습니다.")
            break
        fi
    done

    if [ "$content_mismatch" = false ]; then
        result="양호"
        status+=("$filename 파일의 내용이 정확합니다.")
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
