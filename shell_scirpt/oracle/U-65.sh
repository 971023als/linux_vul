#!/bin/bash

# 초기 진단 결과 및 현황 설정
category="서비스 관리"
code="U-65"
severity="중"
check_item="at 서비스 권한 설정"
result=""
declare -a status
recommendation="일반 사용자의 at 명령어 사용 금지 및 관련 파일 권한 640 이하 설정"

# at 명령어 실행 파일 권한 확인
permission_issues_found=false

# PATH 내 at 명령어 경로 확인 및 권한 검사
for path in ${PATH//:/ }; do
    if [[ -x "$path/at" ]]; then
        permissions=$(stat -c "%a" "$path/at")
        if [[ "$permissions" =~ .*[2-7]. ]]; then
            result="취약"
            permission_issues_found=true
            status+=("$path/at 실행 파일이 다른 사용자(other)에 의해 실행이 가능합니다.")
        fi
    fi
done

# /etc/at.allow 및 /etc/at.deny 파일 권한 확인
at_access_control_files=("/etc/at.allow" "/etc/at.deny")
for file in "${at_access_control_files[@]}"; do
    if [[ -f "$file" ]]; then
        permissions=$(stat -c "%a" "$file")
        file_owner=$(stat -c "%U" "$file")
        if [[ "$file_owner" != "root" ]] || [[ "$permissions" -gt 640 ]]; then
            result="취약"
            permission_issues_found=true
            status+=("$file 파일의 소유자가 $file_owner이고, 권한이 ${permissions}입니다.")
        fi
    fi
done

# 진단 결과 결정
if ! $permission_issues_found; then
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
