#!/bin/bash

# Initialize diagnostic results and current status
category="서비스 관리"
code="U-70"
severity="중"
check_item="expn, vrfy 명령어 제한"
result=""
status=""
recommendation="SMTP 설정에서 noexpn 및 novrfy 옵션 활성화"

# Check for SMTP service
if ! ps -ef | grep -Ei 'smtp|sendmail' | grep -v 'grep' > /dev/null; then
    result="양호"
    status="SMTP 서비스 미사용."
else
    # Find sendmail.cf files
    sendmailcf_files=$(find / -name sendmail.cf -type f 2>/dev/null)
    if [[ -z "$sendmailcf_files" ]]; then
        result="취약"
        status="SMTP 서비스 사용 중이나, noexpn, novrfy 또는 goaway 옵션을 설정할 수 있는 sendmail.cf 파일이 없습니다."
    else
        restriction_found=false
        for file_path in $sendmailcf_files; do
            if [[ -f "$file_path" ]]; then
                if grep -Eiq 'PrivacyOptions.*noexpn' "$file_path" && grep -Eiq 'PrivacyOptions.*novrfy' "$file_path" || grep -Eiq 'PrivacyOptions.*goaway' "$file_path"; then
                    restriction_found=true
                    break
                fi
            fi
        done
        
        if $restriction_found; then
            result="양호"
            status="SMTP 서비스에서 noexpn 및 novrfy 옵션이 적절히 설정되어 있습니다."
        else
            result="취약"
            status="일부 sendmail.cf 파일에 noexpn, novrfy 또는 goaway 설정이 적절히 설정되어 있지 않습니다."
        fi
    fi
fi

# Print the results
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황: $status"
echo "대응방안: $recommendation"
