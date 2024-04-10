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
webconf_files=("httpd.conf" "apache2.conf")
found_files=()
configuration_set_correctly=false

# Search and check configurations
for conf_file in "${webconf_files[@]}"; do
    found_files+=($(find /etc/apache2 /etc/httpd -type f -name "$conf_file" 2>/dev/null))
done

if [ ${#found_files[@]} -eq 0 ]; then
    # If no configuration files found and Apache is running, then it's a vulnerability
    if pgrep -f 'apache2|httpd' > /dev/null; then
        result="취약"
        status="Apache 서비스를 사용하고 있으나, 적절한 설정 파일을 찾을 수 없습니다."
    else
        result="양호"
        status="Apache 서비스 미사용."
    fi
else
    for file_path in "${found_files[@]}"; do
        # Adding or modifying ServerTokens and ServerSignature settings
        sed -i '/^\s*ServerTokens\s/d' "$file_path"
        echo "ServerTokens Prod" >> "$file_path"
        sed -i '/^\s*ServerSignature\s/d' "$file_path"
        echo "ServerSignature Off" >> "$file_path"
        configuration_set_correctly=true
    done

    if $configuration_set_correctly; then
        result="조치 완료"
        status="Apache 설정 파일에 ServerTokens Prod, ServerSignature Off 설정이 추가되었습니다."
    else
        result="취약"
        status="Apache 설정 파일 수정에 실패했습니다."
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
