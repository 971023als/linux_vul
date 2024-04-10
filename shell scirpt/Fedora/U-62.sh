#!/bin/bash

# 초기 진단 결과 및 현황 설정
category="서비스 관리"
code="U-62"
severity="중"
check_item="ftp 계정 shell 제한"
result=""
status=""
recommendation="ftp 계정에 /bin/false 쉘 부여"

# /etc/passwd에서 ftp 계정 확인
if grep -q "^ftp:" /etc/passwd; then
    ftp_shell=$(grep "^ftp:" /etc/passwd | cut -d':' -f7)
    if [ "$ftp_shell" = "/bin/false" ]; then
        result="양호"
        status="ftp 계정에 /bin/false 쉘이 부여되어 있습니다."
    else
        result="취약"
        status="ftp 계정에 /bin/false 쉘이 부여되어 있지 않습니다."
    fi
else
    result="양호"
    status="ftp 계정이 시스템에 존재하지 않습니다."
fi

# 결과 출력
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황: $status"
echo "대응방안: $recommendation"
