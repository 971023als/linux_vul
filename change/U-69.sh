#!/bin/bash

exports_file='/etc/exports'

if [ -e "$exports_file" ]; then
    # Get the file's mode (permissions and ownership)
    mode=$(stat -c "%a" "$exports_file")
    owner_uid=$(stat -c "%u" "$exports_file")

    # Initialize a flag to check if changes are made
    changes_made=false

    # Check if owner is root and file permissions are 644 or less
    if [ "$owner_uid" -ne 0 ]; then
        # Change the file's owner to root
        chown root "$exports_file"
        status="/etc/exports 파일의 소유자를 root로 변경하였습니다."
        changes_made=true
    fi
    
    if [ "$mode" -gt 644 ]; then
        # Change the file permissions to 644
        chmod 644 "$exports_file"
        status+="${status:+ }/etc/exports 파일의 권한을 644로 설정하였습니다."
        changes_made=true
    fi

    if $changes_made; then
        result="조치 완료"
    else
        result="양호"
        status="NFS 접근제어 설정파일의 소유자가 root이고, 권한이 644 이하입니다."
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
