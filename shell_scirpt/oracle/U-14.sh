#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-14"
위험도="상"
진단항목="사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정"
대응방안="홈 디렉터리 환경변수 파일 소유자가 root 또는 해당 계정으로 지정되어 있고, 쓰기 권한이 부여된 경우"
현황=""
진단결과=""

TMP1=$(basename "$0").log
> $TMP1

start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")
vulnerable_files=()

# 모든 사용자 홈 디렉터리 순회
while IFS=: read -r user _ uid _ _ home _; do
    if [ -d "$home" ]; then
        for start_file in "${start_files[@]}"; do
            file_path="$home/$start_file"
            if [ -f "$file_path" ]; then
                file_uid=$(stat -c "%u" "$file_path")
                permissions=$(stat -c "%A" "$file_path")

                # 파일 소유자가 root 또는 해당 사용자가 아니거나, 다른 사용자에게 쓰기 권한이 있을 경우
                if [ "$file_uid" -ne 0 ] && [ "$file_uid" -ne "$uid" ] || [[ $permissions == *w*o ]]; then
                    vulnerable_files+=("$file_path")
                fi
            fi
        done
    fi
done < /etc/passwd

if [ ${#vulnerable_files[@]} -gt 0 ]; then
    진단결과="취약"
    현황=$(printf ", %s" "${vulnerable_files[@]}")
    현황=${현황:2}
else
    진단결과="양호"
    현황="모든 홈 디렉터리 내 시작파일 및 환경파일이 적절한 소유자와 권한 설정을 가지고 있습니다."
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
