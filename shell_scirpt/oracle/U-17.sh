#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-17"
위험도="상"
진단항목="\$HOME/.rhosts, hosts.equiv 사용 금지"
대응방안="login, shell, exec 서비스 사용 시 /etc/hosts.equiv 및 \$HOME/.rhosts 파일 소유자, 권한, 설정 검증"
현황=""
진단결과="양호"

TMP1=$(basename "$0").log
> $TMP1

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
        현황+="$file: 소유자가 $owner_expected가 아님, "
        return 1
    fi

    # 권한 검사 (600 이하인지)
    if [ "$permissions" -gt 600 ]; then
        현황+="$file: 권한이 600보다 큼, "
        return 1
    fi

    # '+' 문자 검사
    if grep -q '+' "$file"; then
        현황+="$file: 파일 내에 '+' 문자가 있음, "
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
            진단결과="취약"
        fi
    fi
done < /etc/passwd

# 결과 업데이트
if [ -z "$현황" ]; then
    현황="login, shell, exec 서비스 사용 시 /etc/hosts.equiv 및 \$HOME/.rhosts 파일 문제 없음"
fi

# 결과를 로그 파일에 기록
echo "현황: $현황" >> $TMP1

# CSV 파일에 결과 추가
echo "$분류,$코드,$위험도,$진단항목,$대응방안,$진단결과,$현황" >> $OUTPUT_CSV

# 로그 파일 출력
cat $TMP1

# CSV 파일 출력
echo ; echo
cat $OUTPUT_CSV
