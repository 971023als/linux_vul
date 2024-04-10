#!/bin/bash

# at 명령어 실행 파일 권한 확인 및 수정
permission_issues_found=false

# PATH 내 at 명령어 경로 확인 및 권한 검사
for path in ${PATH//:/ }; do
    if [[ -x "$path/at" ]]; then
        permissions=$(stat -c "%a" "$path/at")
        if [[ "$permissions" =~ .*[2-7]. ]]; then
            chmod 640 "$path/at"
            status+=("$path/at 실행 파일의 권한을 640으로 수정하였습니다.")
            permission_issues_found=true
        fi
    fi
done

# /etc/at.allow 및 /etc/at.deny 파일 권한 확인 및 수정
at_access_control_files=("/etc/at.allow" "/etc/at.deny")
for file in "${at_access_control_files[@]}"; do
    if [[ -f "$file" ]]; then
        chmod 640 "$file"
        chown root "$file"
        permissions=$(stat -c "%a" "$file")
        file_owner=$(stat -c "%U" "$file")
        status+=("$file 파일의 소유자를 root로, 권한을 ${permissions}으로 수정하였습니다.")
        permission_issues_found=true
    fi
done

# 진단 결과 결정
if $permission_issues_found; then
    result="조치 완료"
    status+=("at 관련 파일 권한 및 소유자 수정을 완료하였습니다.")
else
    result="양호"
    status=("모든 at 관련 파일이 적절한 권한 설정을 가지고 있습니다.")
fi

# 결과 출력
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
