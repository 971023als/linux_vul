#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-17"
위험도="상"
진단_항목="\$HOME/.rhosts, hosts.equiv 사용 금지"
대응방안="login, shell, exec 서비스 사용 시 /etc/hosts.equiv 및 \$HOME/.rhosts 파일 소유자, 권한, 설정 검증"
현황=()
진단_결과="양호"

# /etc/hosts.equiv 파일 검증
check_file_security() {
    local file=$1
    local owner_expected=$2

    if [ ! -e "$file" ]; then
        return 0 # 파일이 없으면 검사하지 않음
    fi

    local owner=$(stat -c '%U' "$file")
    local permissions=$(stat -c '%a' "$file")

    # 소유자 검사
    if [ "$owner" != "$owner_expected" ]; then
        현황+=("$file: 소유자가 $owner_expected가 아님")
        return 1
    fi

    # 권한 검사 (600 이하인지)
    if [ "$permissions" -gt 600 ]; then
        현황+=("$file: 권한이 600보다 큼")
        return 1
    fi

    # '+' 문자 검사
    if grep -q '+' "$file"; then
        현황+=("$file: 파일 내에 '+' 문자가 있음")
        return 1
    fi

    return 0
}

check_file_security "/etc/hosts.equiv" "root"
hosts_equiv_result=$?

# 사용자별 .rhosts 파일 검증
while IFS=: read -r username _ _ _ _ homedir _; do
    if [ -d "$homedir" ] && [ "$homedir" != "/sbin/nologin" ] && [ "$homedir" != "/bin/false" ]; then
        rhosts_path="$homedir/.rhosts"
        check_file_security "$rhosts_path" "$username"
        rhosts_result=$?
        if [ $rhosts_result -ne 0 ]; then
            진단_결과="취약"
        fi
    fi
done < /etc/passwd

# 결과 업데이트
if [ ${#현황[@]} -eq 0 ]; then
    현황+=("login, shell, exec 서비스 사용 시 /etc/hosts.equiv 및 \$HOME/.rhosts 파일 문제 없음")
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
for item in "${현황[@]}"; do
    echo "$item"
done
