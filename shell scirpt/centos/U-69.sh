#!/bin/bash

# Initialize diagnostic results and current status
category="서비스 관리"
code="U-69"
severity="중"
check_item="NFS 설정파일 접근권한"
result=""
status=""
recommendation="NFS 설정파일의 소유자를 root으로 설정하고, 권한을 644 이하로 설정"

exports_file='/etc/exports'

if [ -e "$exports_file" ]; then
    # Get the file's mode (permissions and ownership)
    mode=$(stat -c "%a" "$exports_file")
    owner_uid=$(stat -c "%u" "$exports_file")

    # Check if owner is root and file permissions are 644 or less
    if [ "$owner_uid" -eq 0 ] && [ "$mode" -le 644 ]; then
        result="양호"
        status="NFS 접근제어 설정파일의 소유자가 root이고, 권한이 644 이하입니다."
    else
        result="취약"
        if [ "$owner_uid" -ne 0 ]; then
            status="/etc/exports 파일의 소유자(owner)가 root가 아닙니다."
        fi
        if [ "$mode" -gt 644 ]; then
            status+="${status:+ }/etc/exports 파일의 권한이 644보다 큽니다."
        fi
    fi
else
    result="N/A"
    status="/etc/exports 파일이 없습니다."
fi

# Print the results
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황: $status"
echo "대응방안: $recommendation"
