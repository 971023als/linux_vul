#!/bin/bash

# Initialize diagnostic results and current status
category="서비스 관리"
code="U-71"
severity="중"
check_item="Apache 웹 서비스 정보 숨김"
result=""
status=""
recommendation="ServerTokens Prod, ServerSignature Off로 설정"

# Web configuration files to search for
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
configuration_set_correctly=false

# Search and check configurations
for conf_file in "${webconf_files[@]}"; do
    while IFS= read -r -d '' file_path; do
        if [[ -f "$file_path" ]]; then
            if grep -Eiq '^\s*ServerTokens\s+Prod' "$file_path" && grep -Eiq '^\s*ServerSignature\s+Off' "$file_path"; then
                configuration_set_correctly=true
                break 2 # Exit both loop and if condition as soon as one file is correctly configured
            fi
        fi
    done < <(find / -type f -name "$conf_file" -print0 2>/dev/null)
done

# Determine the diagnostic result
if $configuration_set_correctly; then
    result="양호"
    status="Apache 설정이 적절히 설정되어 있습니다."
else
    if pgrep -f 'apache2|httpd' > /dev/null; then
        result="취약"
        status="Apache 서비스를 사용하고 있으나, ServerTokens Prod, ServerSignature Off 설정이 적절히 구성되어 있지 않습니다."
    else
        result="양호"
        status="Apache 서비스 미사용."
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
